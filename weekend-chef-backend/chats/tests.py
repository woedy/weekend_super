from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APIClient

from django.test import TestCase

from chef.models import ChefProfile
from chats.models import MessageTemplate
from clients.models import Client
from dispatch.models import DispatchDriver
from notifications.models import Notification
from orders.models import Order


User = get_user_model()


class OrderChatThreadTests(TestCase):
    def setUp(self):
        self.api_client = APIClient()
        self.client_user = User.objects.create_user(
            email="client@example.com",
            password="password123",
            first_name="Client",
            last_name="User",
        )
        self.client_user.user_type = "Client"
        self.client_user.save(update_fields=["user_type"])

        self.chef_user = User.objects.create_user(
            email="chef@example.com",
            password="password123",
            first_name="Chef",
            last_name="User",
        )
        self.chef_user.user_type = "Chef"
        self.chef_user.save(update_fields=["user_type"])

        self.dispatch_user = User.objects.create_user(
            email="dispatch@example.com",
            password="password123",
            first_name="Dispatch",
            last_name="User",
        )
        self.dispatch_user.user_type = "Dispatch"
        self.dispatch_user.save(update_fields=["user_type"])

        self.client_profile = Client.objects.create(user=self.client_user)
        self.chef_profile = ChefProfile.objects.create(user=self.chef_user)
        self.dispatch_profile = DispatchDriver.objects.create(user=self.dispatch_user)

        self.order = Order.objects.create(
            client=self.client_profile,
            chef=self.chef_profile,
            total_price=0,
            grocery_advance_amount=0,
            final_payout_amount=0,
            platform_fee_amount=0,
        )

    def authenticate(self, user):
        token = user.auth_token.key
        self.api_client.credentials(HTTP_AUTHORIZATION=f"Token {token}")

    def test_chat_thread_created_and_participants_synced(self):
        thread = self.order.chat_thread
        participants = thread.thread_participants.all()
        self.assertEqual(participants.count(), 2)
        roles = {(p.user.email, p.role) for p in participants}
        self.assertIn((self.client_user.email, thread.Role.CLIENT), roles)
        self.assertIn((self.chef_user.email, thread.Role.CHEF), roles)

    def test_dispatch_added_when_assigned(self):
        thread = self.order.chat_thread
        self.assertFalse(
            thread.thread_participants.filter(user=self.dispatch_user).exists()
        )

        self.order.dispatch = self.dispatch_profile
        self.order.save()

        thread.refresh_from_db()
        self.assertTrue(
            thread.thread_participants.filter(user=self.dispatch_user, role=thread.Role.DISPATCH, is_active=True).exists()
        )

    def test_post_message_notifies_other_participants(self):
        template = MessageTemplate.objects.create(
            key="status-update",
            label="Status update",
            body="Order is ready",
            audience=MessageTemplate.Audience.UNIVERSAL,
        )

        thread = self.order.chat_thread
        self.authenticate(self.client_user)

        url = reverse("chats_api:send_order_thread_message", args=[self.order.order_id or self.order.pk])
        payload = {"body": "Driver is on the way", "template_key": template.key}
        response = self.api_client.post(url, payload, format="json")
        self.assertEqual(response.status_code, 201)

        chef_notifications = Notification.objects.filter(user=self.chef_user).count()
        self.assertEqual(chef_notifications, 1)
        dispatch_notifications = Notification.objects.filter(user=self.dispatch_user).count()
        self.assertEqual(dispatch_notifications, 0)

    def test_thread_access_restricted_to_participants(self):
        outsider = User.objects.create_user(
            email="outsider@example.com",
            password="password123",
            first_name="Outside",
            last_name="User",
        )
        self.authenticate(outsider)
        url = reverse("chats_api:order_thread", args=[self.order.order_id or self.order.pk])
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, 403)

        self.authenticate(self.chef_user)
        response = self.api_client.get(url)
        self.assertEqual(response.status_code, 200)
