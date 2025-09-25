from datetime import timedelta

from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from accounts.models import User
from chef.models import ChefProfile
from clients.models import Client
from dispatch.models import DispatchDriver
from food.models import FoodCategory, Dish
from orders.models import Cart, CartItem, Order


class OrderApiTests(APITestCase):
    def setUp(self):
        self.category = FoodCategory.objects.create(name="Rice")
        self.dish = Dish.objects.create(name="Fried Rice", category=self.category, description="")

        self.client_user = User.objects.create_user(email="client@test.com", password="secret", first_name="Client", last_name="User")
        self.client_user.user_type = "Client"
        self.client_user.save()
        self.client_profile = Client.objects.create(user=self.client_user)
        self.client_token = Token.objects.get(user=self.client_user)

        self.chef_user = User.objects.create_user(email="chef@test.com", password="secret", first_name="Chef", last_name="User")
        self.chef_user.user_type = "Chef"
        self.chef_user.save()
        self.chef_profile = ChefProfile.objects.create(user=self.chef_user)
        self.chef_token = Token.objects.get(user=self.chef_user)

        self.dispatch_user = User.objects.create_user(email="dispatch@test.com", password="secret", first_name="Dispatch", last_name="User")
        self.dispatch_user.user_type = "Dispatch"
        self.dispatch_user.save()
        self.dispatch_profile = DispatchDriver.objects.create(user=self.dispatch_user)
        self.dispatch_token = Token.objects.get(user=self.dispatch_user)

        self.cart = Cart.objects.create(client=self.client_profile)
        self.cart_item = CartItem.objects.create(cart=self.cart, dish=self.dish, quantity=2, value="Large", package="Large", package_price=40)

        self.order_list_url = reverse("orders:v2:order-list")

    def _auth(self, token):
        return {"HTTP_AUTHORIZATION": f"Token {token}"}

    def test_client_can_place_order_and_split_recorded(self):
        payload = {
            "cart": self.cart.pk,
            "chef": self.chef_profile.pk,
            "delivery_window_start": (timezone.now() + timedelta(hours=4)).isoformat(),
            "delivery_window_end": (timezone.now() + timedelta(hours=6)).isoformat(),
        }
        response = self.client.post(self.order_list_url, payload, format="json", **self._auth(self.client_token.key))
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        order = Order.objects.get(pk=response.data["id"])
        self.assertGreater(order.grocery_advance_amount, 0)
        self.assertEqual(order.escrow_entries.count(), 2)

        status_url = reverse("orders:v2:order-status", args=[order.pk])
        response = self.client.post(status_url, {"status": Order.Status.DELIVERED}, format="json", **self._auth(self.chef_token.key))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        order.refresh_from_db()
        self.assertEqual(order.status, Order.Status.DELIVERED)
        self.assertEqual(order.escrow_entries.count(), 3)

    def test_scheduler_prevents_overlap(self):
        payload = {
            "cart": self.cart.pk,
            "chef": self.chef_profile.pk,
            "delivery_window_start": (timezone.now() + timedelta(hours=4)).isoformat(),
            "delivery_window_end": (timezone.now() + timedelta(hours=6)).isoformat(),
        }
        first = self.client.post(self.order_list_url, payload, format="json", **self._auth(self.client_token.key))
        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        second_cart = Cart.objects.create(client=self.client_profile)
        CartItem.objects.create(cart=second_cart, dish=self.dish, quantity=1, value="Large", package="Large", package_price=40)
        payload["cart"] = second_cart.pk
        payload["delivery_window_start"] = (timezone.now() + timedelta(hours=5)).isoformat()
        payload["delivery_window_end"] = (timezone.now() + timedelta(hours=7)).isoformat()
        response = self.client.post(self.order_list_url, payload, format="json", **self._auth(self.client_token.key))
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_dispatcher_can_upload_delivery_proof(self):
        payload = {
            "cart": self.cart.pk,
            "chef": self.chef_profile.pk,
            "delivery_window_start": (timezone.now() + timedelta(hours=1)).isoformat(),
            "delivery_window_end": (timezone.now() + timedelta(hours=2)).isoformat(),
        }
        order_response = self.client.post(self.order_list_url, payload, format="json", **self._auth(self.client_token.key))
        order_id = order_response.data["id"]
        status_url = reverse("orders:v2:order-status", args=[order_id])
        self.client.post(status_url, {"status": Order.Status.DISPATCHED}, format="json", **self._auth(self.chef_token.key))
        proof_url = reverse("orders:v2:order-delivery-proof", args=[order_id])
        response = self.client.post(proof_url, {"signature": "Delivered"}, format="json", **self._auth(self.dispatch_token.key))
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIsNotNone(response.data["signature"])

    def test_rating_requires_delivery(self):
        payload = {
            "cart": self.cart.pk,
            "chef": self.chef_profile.pk,
            "delivery_window_start": (timezone.now() + timedelta(hours=1)).isoformat(),
            "delivery_window_end": (timezone.now() + timedelta(hours=2)).isoformat(),
        }
        order_response = self.client.post(self.order_list_url, payload, format="json", **self._auth(self.client_token.key))
        order_id = order_response.data["id"]
        rating_url = reverse("orders:v2:order-rating", args=[order_id])
        response = self.client.post(rating_url, {"rating": 5}, format="json", **self._auth(self.client_token.key))
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        status_url = reverse("orders:v2:order-status", args=[order_id])
        self.client.post(status_url, {"status": Order.Status.DELIVERED}, format="json", **self._auth(self.chef_token.key))
        response = self.client.post(rating_url, {"rating": 5, "report": "Great"}, format="json", **self._auth(self.client_token.key))
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
