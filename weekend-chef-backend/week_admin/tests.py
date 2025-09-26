from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.test import TestCase

from orders.models import Order


class DemoDataCommandsTest(TestCase):
    def test_seed_and_reset_demo_data(self):
        call_command("seed_demo_data")

        self.assertTrue(Order.objects.filter(order_id="GTM-DEMO-ORDER-1").exists())
        self.assertTrue(Order.objects.filter(order_id="GTM-DEMO-ORDER-2").exists())

        call_command("reset_demo_data")

        self.assertFalse(Order.objects.filter(order_id="GTM-DEMO-ORDER-1").exists())
        self.assertFalse(Order.objects.filter(order_id="GTM-DEMO-ORDER-2").exists())

        User = get_user_model()
        self.assertFalse(User.objects.filter(email="aria.client@weekendchef.demo", is_active=True).exists())
