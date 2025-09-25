from datetime import timedelta

from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from accounts.models import User
from chef.models import ChefProfile
from clients.models import Client
from complaints.models import DisputeTicket
from food.models import FoodCategory, Dish
from orders.models import Cart, CartItem, Order
from orders.services import create_order_with_split


class DisputeTicketTests(APITestCase):
    def setUp(self):
        category = FoodCategory.objects.create(name="Soups")
        dish = Dish.objects.create(name="Pepper Soup", category=category, description="")
        self.client_user = User.objects.create_user(email="dispute-client@test.com", password="secret", first_name="Client", last_name="User")
        self.client_user.user_type = "Client"
        self.client_user.save()
        self.client_profile = Client.objects.create(user=self.client_user)
        self.client_token = Token.objects.get(user=self.client_user)

        self.chef_user = User.objects.create_user(email="dispute-chef@test.com", password="secret", first_name="Chef", last_name="User")
        self.chef_user.user_type = "Chef"
        self.chef_user.save()
        self.chef_profile = ChefProfile.objects.create(user=self.chef_user)

        cart = Cart.objects.create(client=self.client_profile)
        CartItem.objects.create(cart=cart, dish=dish, quantity=1, value="Large", package="Large", package_price=30)
        self.order = Order(
            cart=cart,
            client=self.client_profile,
            chef=self.chef_profile,
            total_price=30,
            delivery_window_start=timezone.now() + timedelta(hours=2),
            delivery_window_end=timezone.now() + timedelta(hours=3),
        )
        create_order_with_split(self.order)

        self.admin_user = User.objects.create_superuser(email="admin@test.com", password="secret", first_name="Admin", last_name="User")
        self.admin_user.user_type = "Admin"
        self.admin_user.save()
        self.admin_token = Token.objects.get(user=self.admin_user)

        self.list_url = reverse("complaints:v2:dispute-list")

    def _auth(self, token):
        return {"HTTP_AUTHORIZATION": f"Token {token}"}

    def test_client_can_create_dispute(self):
        payload = {"order": self.order.pk, "description": "Meal arrived cold"}
        response = self.client.post(self.list_url, payload, format="json", **self._auth(self.client_token.key))
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(DisputeTicket.objects.count(), 1)

    def test_admin_can_resolve_dispute_with_adjustment(self):
        ticket = DisputeTicket.objects.create(order=self.order, raised_by=self.client_user, description="Issue")
        resolve_url = reverse("complaints:v2:dispute-resolve", args=[ticket.pk])
        payload = {"status": "resolved", "resolution_notes": "Refund issued", "payout_adjustment": "-5"}
        response = self.client.patch(resolve_url, payload, format="json", **self._auth(self.admin_token.key))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ticket.refresh_from_db()
        self.assertEqual(ticket.status, "resolved")
        self.order.refresh_from_db()
        self.assertEqual(self.order.escrow_entries.filter(entry_type="refund").count(), 1)
