from __future__ import annotations

from datetime import timedelta
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.test import TestCase, override_settings
from django.urls import reverse
from django.utils import timezone

from chef.models import ChefProfile
from clients.models import Client
from dispatch.models import DispatchDriver
from food.models import FoodCategory, Dish
from orders.models import Cart, CartItem, Order
from orders.services import transition_order


class OrderLifecycleTests(TestCase):
    def setUp(self):
        self.user_model = get_user_model()
        self.password = "QaSmoke123!"
        self.category = FoodCategory.objects.create(name="QA Meals", description="Test catalog entries")
        self.dish = Dish.objects.create(
            name="QA Signature Bowl",
            category=self.category,
            description="Smoke test dish",
            large_price=Decimal("42.00"),
            large_value="Family",
            active=True,
        )
        self.expected_total = Decimal("0")

    def _create_order(self) -> Order:
        timestamp = timezone.now().strftime("%H%M%S%f")

        client_user = self.user_model.objects.create_user(
            email=f"test-client-{timestamp}@example.com",
            password=self.password,
            first_name="QA",
            last_name="Client",
        )
        client_user.user_type = "Client"
        client_user.email_verified = True
        client_user.phone = "+15550000001"
        client_user.phone_verified = True
        client_user.save(update_fields=["user_type", "email_verified", "phone", "phone_verified"])
        client = Client.objects.create(user=client_user)

        chef_user = self.user_model.objects.create_user(
            email=f"test-chef-{timestamp}@example.com",
            password=self.password,
            first_name="QA",
            last_name="Chef",
        )
        chef_user.user_type = "Chef"
        chef_user.save(update_fields=["user_type"])
        chef = ChefProfile.objects.create(
            user=chef_user,
            active=True,
            review_status=ChefProfile.ReviewStatus.APPROVED,
        )

        dispatch_user = self.user_model.objects.create_user(
            email=f"test-dispatch-{timestamp}@example.com",
            password=self.password,
            first_name="QA",
            last_name="Dispatch",
        )
        dispatch_user.user_type = "Dispatch"
        dispatch_user.save(update_fields=["user_type"])
        dispatch_driver = DispatchDriver.objects.create(user=dispatch_user, vehicle_type="Bike")

        cart = Cart.objects.create(client=client)
        CartItem.objects.create(
            cart=cart,
            dish=self.dish,
            quantity=2,
            value="Family",
            package="Family",
            package_price=Decimal("42.00"),
            item_total_price=Decimal("84.00"),
        )

        expected_total = sum(item.total_price() for item in cart.items.all())
        self.assertGreater(expected_total, 0)
        self.expected_total = expected_total

        order = Order(
            cart=cart,
            client=client,
            chef=chef,
            dispatch=dispatch_driver,
            delivery_window_start=timezone.now() + timedelta(hours=1),
            delivery_window_end=timezone.now() + timedelta(hours=2),
        )
        order.total_price = expected_total
        order.full_clean()
        order.save()

        transition_order(order, Order.Status.ACCEPTED, changed_by=chef_user)
        transition_order(order, Order.Status.COOKING, changed_by=chef_user)
        transition_order(order, Order.Status.DISPATCHED, changed_by=dispatch_user)
        transition_order(order, Order.Status.DELIVERED, changed_by=dispatch_user)
        transition_order(order, Order.Status.COMPLETED, changed_by=client_user)

        return order

    def test_payout_entries_created_when_order_completed(self):
        order = self._create_order()

        order.refresh_from_db()
        entry_types = list(order.escrow_entries.values_list("entry_type", flat=True))
        self.assertEqual(Order.Status.COMPLETED, order.status)
        self.assertIn("grocery_advance", entry_types)
        self.assertIn("platform_fee", entry_types)
        self.assertIn("final_payout", entry_types)
        amounts = {entry.entry_type: entry.amount for entry in order.escrow_entries.all()}
        self.assertGreater(amounts["grocery_advance"], 0)
        self.assertGreater(self.expected_total, 0)
        self.assertEqual(
            amounts["grocery_advance"] + amounts["platform_fee"] + amounts["final_payout"],
            self.expected_total,
        )

    @override_settings(QA_SMOKE_ENABLED=True)
    def test_smoke_endpoint_returns_completed_order_payload(self):
        response = self.client.post(reverse("qa_order_smoke"))
        self.assertEqual(response.status_code, 200)
        payload = response.json()
        self.assertEqual(payload["status"], "completed")
        self.assertTrue(payload["order_id"])
        ledger_types = {entry["entry_type"] for entry in payload["ledger"]}
        self.assertSetEqual(
            {"grocery_advance", "platform_fee", "final_payout"},
            ledger_types,
        )
        total = Decimal(payload["totals"]["total_price"])
        self.assertGreater(total, 0)
        ledger_total = sum(Decimal(entry["amount"]) for entry in payload["ledger"])
        self.assertEqual(total, ledger_total)
