from django.urls import reverse
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from accounts.models import User


class NotificationPreferenceTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(email="notify@test.com", password="secret", first_name="Notify", last_name="User")
        self.token = Token.objects.get(user=self.user)
        self.url = reverse("notifications:v2:preferences")

    def test_user_can_update_notification_preferences(self):
        response = self.client.get(self.url, **{"HTTP_AUTHORIZATION": f"Token {self.token.key}"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("marketing_updates", response.data)
        self.assertFalse(response.data["marketing_updates"])
        initial_timestamp = response.data["consent_updated_at"]

        payload = {
            "email_updates": False,
            "sms_updates": True,
            "marketing_updates": True,
            "consent_source": "mobile-app",
            "consent_version": "2024-privacy",
        }
        response = self.client.patch(self.url, payload, format="json", **{"HTTP_AUTHORIZATION": f"Token {self.token.key}"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data["email_updates"])
        self.assertTrue(response.data["sms_updates"])
        self.assertTrue(response.data["marketing_updates"])
        self.assertEqual(response.data["consent_source"], "mobile-app")
        self.assertEqual(response.data["consent_version"], "2024-privacy")
        self.assertNotEqual(response.data["consent_updated_at"], initial_timestamp)
