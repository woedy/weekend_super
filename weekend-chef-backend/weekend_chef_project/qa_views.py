from __future__ import annotations

from datetime import timedelta
from decimal import Decimal

from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import transaction
from django.http import Http404, JsonResponse
from django.utils import timezone
from django.views.decorators.http import require_http_methods

from chef.models import ChefProfile
from clients.models import Client
from dispatch.models import DispatchDriver
from food.models import FoodCategory, Dish
from orders.models import Cart, CartItem, Order
from orders.services import transition_order


@require_http_methods(["POST"])
def order_smoke_test(request):
    """Provision a temporary order and walk it through the lifecycle for smoke testing."""

    if not getattr(settings, "QA_SMOKE_ENABLED", settings.DEBUG):  # pragma: no cover - explicit guard branch
        raise Http404()

    with transaction.atomic():
        timestamp = timezone.now().strftime("%Y%m%d%H%M%S%f")
        password = "QaSmoke123!"

        user_model = get_user_model()

        client_user = user_model.objects.create_user(
            email=f"qa-client-{timestamp}@example.com",
            password=password,
            first_name="QA",
            last_name="Client",
        )
        client_user.user_type = "Client"
        client_user.email_verified = True
        client_user.phone = "+15550000001"
        client_user.phone_verified = True
        client_user.save(update_fields=["user_type", "email_verified", "phone", "phone_verified"])
        client = Client.objects.create(user=client_user)

        chef_user = user_model.objects.create_user(
            email=f"qa-chef-{timestamp}@example.com",
            password=password,
            first_name="QA",
            last_name="Chef",
        )
        chef_user.user_type = "Chef"
        chef_user.save(update_fields=["user_type"])
        chef_profile = ChefProfile.objects.create(
            user=chef_user,
            active=True,
            review_status=ChefProfile.ReviewStatus.APPROVED,
        )

        dispatch_user = user_model.objects.create_user(
            email=f"qa-dispatch-{timestamp}@example.com",
            password=password,
            first_name="QA",
            last_name="Dispatch",
        )
        dispatch_user.user_type = "Dispatch"
        dispatch_user.save(update_fields=["user_type"])
        dispatch_driver = DispatchDriver.objects.create(user=dispatch_user, vehicle_type="Scooter")

        category, _ = FoodCategory.objects.get_or_create(
            name="QA Smoke Meals",
            defaults={"description": "Synthetic catalog entries for automated QA."},
        )
        dish, _ = Dish.objects.get_or_create(
            name="QA Smoke Bowl",
            category=category,
            defaults={
                "description": "Automated scenario coverage meal.",
                "large_price": Decimal("48.00"),
                "large_value": "Family",
                "active": True,
            },
        )

        cart = Cart.objects.create(client=client)
        CartItem.objects.create(
            cart=cart,
            dish=dish,
            quantity=1,
            value="Family",
            package="Family",
            package_price=Decimal("48.00"),
            item_total_price=Decimal("48.00"),
        )

        order_total = sum(item.total_price() for item in cart.items.all())
        if order_total <= 0:
            raise ValueError("QA smoke order total must be positive")

        order = Order(
            cart=cart,
            client=client,
            chef=chef_profile,
            dispatch=dispatch_driver,
            delivery_window_start=timezone.now() + timedelta(hours=1),
            delivery_window_end=timezone.now() + timedelta(hours=2),
        )
        order.total_price = order_total
        order.full_clean()
        order.save()

        transition_order(order, Order.Status.ACCEPTED, changed_by=chef_user)
        transition_order(order, Order.Status.COOKING, changed_by=chef_user)
        transition_order(order, Order.Status.READY, changed_by=chef_user)
        transition_order(order, Order.Status.DISPATCHED, changed_by=dispatch_user)
        transition_order(order, Order.Status.DELIVERED, changed_by=dispatch_user)
        transition_order(order, Order.Status.COMPLETED, changed_by=client_user)

        ledger = [
            {
                "entry_type": entry.entry_type,
                "amount": str(entry.amount),
                "processed_at": entry.processed_at.isoformat(),
            }
            for entry in order.escrow_entries.all()
        ]
        timeline = [
            {
                "status": transition.status,
                "changed_at": transition.changed_at.isoformat(),
            }
            for transition in order.status_transitions.order_by("-changed_at")
        ]

    return JsonResponse(
        {
            "order_id": order.order_id,
            "status": order.status,
            "ledger": ledger,
            "timeline": timeline,
            "totals": {
                "total_price": str(order.total_price),
                "grocery_advance_amount": str(order.grocery_advance_amount),
                "final_payout_amount": str(order.final_payout_amount),
                "platform_fee_amount": str(order.platform_fee_amount),
            },
        }
    )
