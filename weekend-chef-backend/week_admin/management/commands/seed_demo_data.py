from decimal import Decimal
from typing import Dict, List

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand
from django.core.management import call_command
from django.db import transaction
from django.utils import timezone

from chef.models import ChefDish, ChefProfile, CuisineSpecialty, Certification
from clients.models import Allergy, Client, ClientHomeLocation, DietaryPreference
from dispatch.models import DispatchDriver
from food.models import CustomizationOption, Dish, DishIngredient, FoodCategory
from orders.models import Cart, CartItem, EscrowLedgerEntry, Order, OrderAllergenReport, OrderItem


DEMO_USERS: List[Dict[str, str]] = [
    {
        "email": "aria.client@weekendchef.demo",
        "first_name": "Aria",
        "last_name": "Nguyen",
        "user_type": "Client",
        "password": "cookdemo123",
        "phone": "+1-415-555-0110",
        "city": "San Francisco",
    },
    {
        "email": "marco.client@weekendchef.demo",
        "first_name": "Marco",
        "last_name": "Diaz",
        "user_type": "Client",
        "password": "cookdemo123",
        "phone": "+1-415-555-0115",
        "city": "San Francisco",
    },
    {
        "email": "chef.lina@weekendchef.demo",
        "first_name": "Lina",
        "last_name": "Hart",
        "user_type": "Chef",
        "password": "cookdemo123",
        "phone": "+1-415-555-0120",
        "city": "San Francisco",
    },
    {
        "email": "chef.omar@weekendchef.demo",
        "first_name": "Omar",
        "last_name": "Rahman",
        "user_type": "Chef",
        "password": "cookdemo123",
        "phone": "+1-415-555-0124",
        "city": "San Francisco",
    },
    {
        "email": "dispatch.jules@weekendchef.demo",
        "first_name": "Jules",
        "last_name": "Kim",
        "user_type": "Dispatch",
        "password": "cookdemo123",
        "phone": "+1-415-555-0128",
        "city": "San Francisco",
    },
    {
        "email": "investor.host@weekendchef.demo",
        "first_name": "Avery",
        "last_name": "Stone",
        "user_type": "Admin",
        "password": "cookdemo123",
        "phone": "+1-415-555-0130",
        "city": "San Francisco",
    },
]


DEMO_CATEGORIES = [
    {
        "name": "Investor Demo Comfort Classics",
        "description": "Showcase mains that highlight our family-style capabilities.",
    },
    {
        "name": "Investor Demo Wellness Bowls",
        "description": "Vibrant, nutrient-dense meals for active clients.",
    },
]


DEMO_DISHES = [
    {
        "name": "Citrus Herb Roast Chicken",
        "category": "Investor Demo Comfort Classics",
        "description": "Free-range chicken roasted with lemon, rosemary, and thyme."
                        " Served with garlic roasted potatoes and charred broccolini.",
        "price_points": {
            "small_price": Decimal("38.00"),
            "medium_price": Decimal("58.00"),
            "large_price": Decimal("92.00"),
            "large_value": "Serves 6"
        },
        "ingredients": [
            {"name": "Whole chicken", "quantity": Decimal("1"), "unit": "ea"},
            {"name": "Meyer lemon", "quantity": Decimal("3"), "unit": "ea"},
            {"name": "Rosemary", "quantity": Decimal("20"), "unit": "g"},
        ],
        "chef_email": "chef.lina@weekendchef.demo",
    },
    {
        "name": "Charred Citrus Salmon",
        "category": "Investor Demo Comfort Classics",
        "description": "Norwegian salmon seared with blood orange glaze, fennel pollen," \
                        " and roasted root vegetables.",
        "price_points": {
            "small_price": Decimal("42.00"),
            "medium_price": Decimal("64.00"),
            "large_price": Decimal("99.00"),
            "large_value": "Serves 6"
        },
        "ingredients": [
            {"name": "Atlantic salmon", "quantity": Decimal("1.80"), "unit": "kg"},
            {"name": "Blood oranges", "quantity": Decimal("4"), "unit": "ea"},
            {"name": "Fennel", "quantity": Decimal("1"), "unit": "bulb"},
        ],
        "chef_email": "chef.lina@weekendchef.demo",
    },
    {
        "name": "Coconut Turmeric Power Bowl",
        "category": "Investor Demo Wellness Bowls",
        "description": "Roasted sweet potatoes, kale, and quinoa with coconut-turmeric"
                        " dressing and toasted pepitas.",
        "price_points": {
            "small_price": Decimal("32.00"),
            "medium_price": Decimal("48.00"),
            "large_price": Decimal("76.00"),
            "large_value": "Serves 4"
        },
        "ingredients": [
            {"name": "Tri-color quinoa", "quantity": Decimal("0.80"), "unit": "kg"},
            {"name": "Dinosaur kale", "quantity": Decimal("2"), "unit": "bunch"},
            {"name": "Turmeric", "quantity": Decimal("15"), "unit": "g"},
        ],
        "chef_email": "chef.omar@weekendchef.demo",
    },
    {
        "name": "Za'atar Cauliflower Mezze",
        "category": "Investor Demo Wellness Bowls",
        "description": "Roasted cauliflower tossed in za'atar with preserved lemon"
                        " labneh and pomegranate molasses.",
        "price_points": {
            "small_price": Decimal("28.00"),
            "medium_price": Decimal("44.00"),
            "large_price": Decimal("70.00"),
            "large_value": "Serves 4"
        },
        "ingredients": [
            {"name": "Cauliflower", "quantity": Decimal("2.0"), "unit": "head"},
            {"name": "Za'atar blend", "quantity": Decimal("35"), "unit": "g"},
            {"name": "Labneh", "quantity": Decimal("0.80"), "unit": "kg"},
        ],
        "chef_email": "chef.omar@weekendchef.demo",
    },
]


DEMO_CUSTOMIZATIONS = [
    {
        "name": "Demo Family Style Packaging",
        "option_type": "Portion",
        "description": "Switch between individual plating and family-style platters.",
        "price": Decimal("0"),
    },
    {
        "name": "Demo Protein Boost",
        "option_type": "Protein",
        "description": "Add organic tofu or grilled chicken to power bowls.",
        "price": Decimal("8.00"),
    },
]


DEMO_ALLERGIES = [
    {"name": "Demo Tree Nut Allergy", "severity": "Medium"},
]

DEMO_DIETARY_PREFS = [
    {"name": "Demo High-Protein", "description": "Macro-balanced for fitness-focused clients."},
    {"name": "Demo Plant-Forward", "description": "Vegan and vegetarian friendly."},
]

DEMO_SPECIALTIES = [
    {"name": "Regional Comforts", "description": "Heritage-inspired comfort dishes."},
    {"name": "Plant-Forward Cuisine", "description": "Seasonal plant-based menus."},
]

DEMO_CERTIFICATIONS = [
    {"name": "ServSafe Manager (Demo)", "description": "Food safety certification for demos."},
    {"name": "Allergen Awareness (Demo)", "description": "Allergen handling for investor tastings."},
]

DEMO_ORDER_IDS = ["GTM-DEMO-ORDER-1", "GTM-DEMO-ORDER-2"]


class Command(BaseCommand):
    help = "Seed demo data for investor walkthroughs."

    @transaction.atomic
    def handle(self, *args, **options):
        self.stdout.write("Resetting existing demo records…")
        call_command("reset_demo_data")
        self.stdout.write("Creating demo fixtures…")
        demo_context = self._seed_core_data()
        self._seed_orders(demo_context)
        self.stdout.write(self.style.SUCCESS("Demo environment is ready."))

    def _seed_core_data(self):
        User = get_user_model()
        demo_users = {}
        for payload in DEMO_USERS:
            defaults = {
                "first_name": payload["first_name"],
                "last_name": payload["last_name"],
                "user_type": payload["user_type"],
                "phone": payload["phone"],
                "location_name": payload["city"],
                "profile_complete": True,
                "verified": True,
                "is_active": True,
            }
            user, created = User.objects.get_or_create(email=payload["email"], defaults=defaults)
            if not created:
                for field, value in defaults.items():
                    setattr(user, field, value)
            user.set_password(payload["password"])
            user.save()
            demo_users[payload["email"]] = user

        dietary_preferences = {}
        for pref in DEMO_DIETARY_PREFS:
            obj, _ = DietaryPreference.objects.get_or_create(name=pref["name"], defaults={"description": pref["description"]})
            dietary_preferences[pref["name"]] = obj

        allergies = {}
        for allergy in DEMO_ALLERGIES:
            obj, _ = Allergy.objects.get_or_create(name=allergy["name"], defaults={"severity": allergy["severity"], "description": "Demo allergen tracking."})
            allergies[allergy["name"]] = obj

        categories = {}
        for category in DEMO_CATEGORIES:
            obj, _ = FoodCategory.objects.get_or_create(name=category["name"], defaults={"description": category["description"], "active": True})
            categories[category["name"]] = obj

        customizations = {}
        for custom in DEMO_CUSTOMIZATIONS:
            obj, _ = CustomizationOption.objects.get_or_create(name=custom["name"], defaults={
                "option_type": custom["option_type"],
                "description": custom["description"],
                "price": custom["price"],
                "active": True,
            })
            customizations[custom["name"]] = obj

        specialties = {}
        for specialty in DEMO_SPECIALTIES:
            obj, _ = CuisineSpecialty.objects.get_or_create(name=specialty["name"], defaults={"description": specialty["description"], "active": True})
            specialties[specialty["name"]] = obj

        certifications = {}
        for cert in DEMO_CERTIFICATIONS:
            obj, _ = Certification.objects.get_or_create(name=cert["name"], defaults={"description": cert["description"], "active": True})
            certifications[cert["name"]] = obj

        demo_clients = {}
        for payload in DEMO_USERS:
            if payload["user_type"] != "Client":
                continue
            user = demo_users[payload["email"]]
            client_defaults = {
                "city": payload["city"],
                "client_type": "Busy Professional",
                "active": True,
            }
            client, _ = Client.objects.update_or_create(user=user, defaults=client_defaults)
            client.dietary_preferences.set(dietary_preferences.values())
            client.allergies.set(allergies.values())
            ClientHomeLocation.objects.update_or_create(
                client=client,
                location_name="Downtown Loft" if payload["email"].startswith("aria") else "Mission Loft",
                defaults={
                    "digital_address": "94107",
                    "lat": Decimal("37.779026"),
                    "lng": Decimal("-122.419906"),
                    "active": True,
                },
            )
            demo_clients[payload["email"]] = client

        demo_chefs = {}
        for payload in DEMO_USERS:
            if payload["user_type"] != "Chef":
                continue
            user = demo_users[payload["email"]]
            chef_defaults = {
                "chef_type": "Professional Chef",
                "kitchen_address": f"{payload['city']} Test Kitchen",
                "service_radius": 15,
                "availability": "Both",
                "years_of_experience": 8,
                "active": True,
                "review_status": ChefProfile.ReviewStatus.APPROVED,
            }
            chef, _ = ChefProfile.objects.update_or_create(user=user, defaults=chef_defaults)
            chef.cuisine_specialties.set(specialties.values())
            chef.certifications.set(certifications.values())
            chef.save()
            demo_chefs[payload["email"]] = chef

        dispatch_payload = next(user for user in DEMO_USERS if user["user_type"] == "Dispatch")
        DispatchDriver.objects.update_or_create(
            user=demo_users[dispatch_payload["email"]],
            defaults={
                "vehicle_type": "EV Hatchback",
                "zones_covered": "Downtown, Mission",
            },
        )

        dishes = {}
        for dish_payload in DEMO_DISHES:
            category = categories[dish_payload["category"]]
            dish, _ = Dish.objects.update_or_create(
                name=dish_payload["name"],
                defaults={
                    "category": category,
                    "description": dish_payload["description"],
                    "active": True,
                    "large_value": dish_payload["price_points"].get("large_value"),
                    "small_price": dish_payload["price_points"].get("small_price"),
                    "medium_price": dish_payload["price_points"].get("medium_price"),
                    "large_price": dish_payload["price_points"].get("large_price"),
                },
            )
            DishIngredient.objects.filter(dish=dish).delete()
            for ingredient in dish_payload["ingredients"]:
                DishIngredient.objects.create(
                    dish=dish,
                    name=ingredient["name"],
                    description=f"Demo ingredient for {dish.name}",
                    quantity=ingredient["quantity"],
                    unit=ingredient["unit"],
                    active=True,
                )
            chef = demo_chefs[dish_payload["chef_email"]]
            chef_dish, _ = ChefDish.objects.update_or_create(
                chef=chef,
                dish=dish,
                defaults={
                    "small_price": dish_payload["price_points"].get("small_price"),
                    "medium_price": dish_payload["price_points"].get("medium_price"),
                    "large_price": dish_payload["price_points"].get("large_price"),
                    "large_value": dish_payload["price_points"].get("large_value"),
                    "active": True,
                    "grocery_budget_estimate": dish_payload["price_points"].get("medium_price", Decimal("0")) * Decimal("0.35"),
                },
            )
            chef_dish.clean()
            chef_dish.save()
            dishes[dish_payload["name"]] = dish

        return {
            "users": demo_users,
            "clients": demo_clients,
            "chefs": demo_chefs,
            "dishes": dishes,
            "customizations": customizations,
            "allergies": allergies,
        }

    def _seed_orders(self, context):
        now = timezone.now()
        aria = context["clients"]["aria.client@weekendchef.demo"]
        marco = context["clients"]["marco.client@weekendchef.demo"]
        citrus_chicken = context["dishes"]["Citrus Herb Roast Chicken"]
        power_bowl = context["dishes"]["Coconut Turmeric Power Bowl"]
        dispatch_user = context["users"]["dispatch.jules@weekendchef.demo"]

        carts = {}
        for client_key, client in [("aria", aria), ("marco", marco)]:
            Cart.objects.filter(client=client).delete()
            cart = Cart.objects.create(client=client, purchased=True)
            carts[client_key] = cart

        CartItem.objects.filter(cart__in=carts.values()).delete()

        aria_item = CartItem.objects.create(
            cart=carts["aria"],
            dish=citrus_chicken,
            quantity=1,
            package="large",
            package_price=Decimal("92.00"),
            item_total_price=Decimal("92.00"),
            value="Family"
        )

        marco_item = CartItem.objects.create(
            cart=carts["marco"],
            dish=power_bowl,
            quantity=1,
            package="medium",
            package_price=Decimal("48.00"),
            item_total_price=Decimal("48.00"),
            value="Meal Prep"
        )

        order_one_defaults = {
            "cart": carts["aria"],
            "chef": context["chefs"]["chef.lina@weekendchef.demo"],
            "dispatch": DispatchDriver.objects.get(user=dispatch_user),
            "total_price": Decimal("142.00"),
            "grocery_advance_amount": Decimal("40.00"),
            "final_payout_amount": Decimal("90.00"),
            "platform_fee_amount": Decimal("12.00"),
            "delivery_fee": Decimal("10.00"),
            "tax": Decimal("8.00"),
            "delivery_window_start": now - timezone.timedelta(days=3, hours=2),
            "delivery_window_end": now - timezone.timedelta(days=3),
            "status": Order.Status.DELIVERED,
            "paid": True,
        }
        order_one, _ = Order.objects.update_or_create(
            order_id=DEMO_ORDER_IDS[0],
            defaults={
                **order_one_defaults,
                "client": aria,
            },
        )

        order_two_defaults = {
            "cart": carts["marco"],
            "chef": context["chefs"]["chef.omar@weekendchef.demo"],
            "dispatch": DispatchDriver.objects.get(user=dispatch_user),
            "total_price": Decimal("58.00"),
            "grocery_advance_amount": Decimal("18.00"),
            "final_payout_amount": Decimal("34.00"),
            "platform_fee_amount": Decimal("6.00"),
            "delivery_fee": Decimal("6.00"),
            "tax": Decimal("4.00"),
            "delivery_window_start": now + timezone.timedelta(days=1, hours=18),
            "delivery_window_end": now + timezone.timedelta(days=1, hours=20),
            "status": Order.Status.ACCEPTED,
            "paid": True,
        }
        order_two, _ = Order.objects.update_or_create(
            order_id=DEMO_ORDER_IDS[1],
            defaults={
                **order_two_defaults,
                "client": marco,
            },
        )

        OrderItem.objects.filter(order__order_id__in=DEMO_ORDER_IDS).delete()
        OrderItem.objects.create(order=order_one, cart_item=aria_item, quantity=aria_item.quantity)
        OrderItem.objects.create(order=order_two, cart_item=marco_item, quantity=marco_item.quantity)

        EscrowLedgerEntry.objects.filter(order__order_id__in=DEMO_ORDER_IDS).delete()
        EscrowLedgerEntry.objects.create(order=order_one, entry_type=EscrowLedgerEntry.EntryType.GROCERY_ADVANCE, amount=order_one.grocery_advance_amount, reference="ACH-2193")
        EscrowLedgerEntry.objects.create(order=order_one, entry_type=EscrowLedgerEntry.EntryType.PLATFORM_FEE, amount=order_one.platform_fee_amount, reference="FEE-2193")
        EscrowLedgerEntry.objects.create(order=order_one, entry_type=EscrowLedgerEntry.EntryType.FINAL_PAYOUT, amount=order_one.final_payout_amount, reference="PAYOUT-2193")
        EscrowLedgerEntry.objects.create(order=order_two, entry_type=EscrowLedgerEntry.EntryType.GROCERY_ADVANCE, amount=order_two.grocery_advance_amount, reference="ACH-4821")

        OrderAllergenReport.objects.update_or_create(
            order=order_one,
            defaults={
                "reported_by_client": True,
                "reported_at": now - timezone.timedelta(days=3, hours=1),
                "acknowledged_by_chef": True,
                "acknowledged_at": now - timezone.timedelta(days=3, minutes=30),
                "acknowledgement_notes": "Chef Lina confirmed prep in dedicated allergen-free area.",
            },
        )
        order_one.allergen_report.allergies.set(context["allergies"].values())

        OrderAllergenReport.objects.update_or_create(
            order=order_two,
            defaults={
                "reported_by_client": True,
                "custom_allergy_notes": "No sesame garnish on plating.",
            },
        )

        self.stdout.write("Created demo orders and financial traces.")
