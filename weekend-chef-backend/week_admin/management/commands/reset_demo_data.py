from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand
from django.db import transaction
from django.db.utils import OperationalError, ProgrammingError

from chef.models import ChefDish, CuisineSpecialty, Certification
from clients.models import Allergy, Client, DietaryPreference
from dispatch.models import DispatchDriver
from food.models import CustomizationOption, Dish, FoodCategory
from orders.models import Cart, EscrowLedgerEntry, Order


DEMO_EMAILS = {
    "aria.client@weekendchef.demo",
    "marco.client@weekendchef.demo",
    "chef.lina@weekendchef.demo",
    "chef.omar@weekendchef.demo",
    "dispatch.jules@weekendchef.demo",
    "investor.host@weekendchef.demo",
}

DEMO_CATEGORY_NAMES = {
    "Investor Demo Comfort Classics",
    "Investor Demo Wellness Bowls",
}

DEMO_DISH_NAMES = {
    "Citrus Herb Roast Chicken",
    "Charred Citrus Salmon",
    "Coconut Turmeric Power Bowl",
    "Za'atar Cauliflower Mezze",
}

DEMO_CUSTOMIZATION_NAMES = {
    "Demo Family Style Packaging",
    "Demo Protein Boost",
}

DEMO_SPECIALTY_NAMES = {
    "Regional Comforts",
    "Plant-Forward Cuisine",
}

DEMO_CERTIFICATION_NAMES = {
    "ServSafe Manager (Demo)",
    "Allergen Awareness (Demo)",
}

DEMO_DIETARY_PREF_NAMES = {
    "Demo High-Protein",
    "Demo Plant-Forward",
}

DEMO_ALLERGY_NAMES = {
    "Demo Tree Nut Allergy",
}

DEMO_ORDER_IDS = ["GTM-DEMO-ORDER-1", "GTM-DEMO-ORDER-2"]


class Command(BaseCommand):
    help = "Remove demo data seeded for investor walkthroughs."

    @transaction.atomic
    def handle(self, *args, **options):
        self.stdout.write("Cleaning demo orders and financial records…")
        Order.objects.filter(order_id__in=DEMO_ORDER_IDS).delete()
        EscrowLedgerEntry.objects.filter(order__isnull=True).delete()

        self.stdout.write("Cleaning demo carts…")
        Cart.objects.filter(client__user__email__in=DEMO_EMAILS).delete()

        self.stdout.write("Removing demo-specific food catalog entries…")
        ChefDish.objects.filter(chef__user__email__in=DEMO_EMAILS).delete()
        Dish.objects.filter(name__in=DEMO_DISH_NAMES).delete()
        FoodCategory.objects.filter(name__in=DEMO_CATEGORY_NAMES).delete()
        CustomizationOption.objects.filter(name__in=DEMO_CUSTOMIZATION_NAMES).delete()

        CuisineSpecialty.objects.filter(name__in=DEMO_SPECIALTY_NAMES).delete()
        Certification.objects.filter(name__in=DEMO_CERTIFICATION_NAMES).delete()

        DietaryPreference.objects.filter(name__in=DEMO_DIETARY_PREF_NAMES).delete()
        Allergy.objects.filter(name__in=DEMO_ALLERGY_NAMES).delete()

        self.stdout.write("Removing demo dispatchers and customers…")
        DispatchDriver.objects.filter(user__email__in=DEMO_EMAILS).delete()
        Client.objects.filter(user__email__in=DEMO_EMAILS).delete()

        User = get_user_model()
        try:
            User.objects.filter(email__in=DEMO_EMAILS).delete()
        except (OperationalError, ProgrammingError):
            User.objects.filter(email__in=DEMO_EMAILS).update(
                is_active=False,
                is_archived=True,
                profile_complete=False,
            )

        self.stdout.write(self.style.SUCCESS("Demo data cleared."))
