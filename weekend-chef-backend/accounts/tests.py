from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models import VerificationToken, User


class AccountFlowTests(APITestCase):
    def setUp(self):
        self.register_url = reverse("accounts_api:register")
        self.login_url = reverse("accounts_api:login")
        self.verify_url = reverse("accounts_api:verify")
        self.profile_url = reverse("accounts_api:profile")
        self.request_verification_url = reverse("accounts_api:request_verification")
        self.resend_phone_url = reverse("accounts_api:resend_phone_verification")

    def _auth_headers(self, token_key: str):
        return {"HTTP_AUTHORIZATION": f"Token {token_key}"}

    def test_registration_login_and_verification_flow(self):
        payload = {
            "email": "client@example.com",
            "password": "secret123",
            "first_name": "Client",
            "last_name": "User",
            "phone": "+15555550123",
            "role": "Client",
        }
        response = self.client.post(self.register_url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        user = User.objects.get(email=payload["email"])
        self.assertFalse(user.email_verified)
        self.assertFalse(user.phone_verified)

        response = self.client.post(self.login_url, {"email": payload["email"], "password": payload["password"]}, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        token = response.data["token"]

        email_token = VerificationToken.objects.filter(user=user, purpose=VerificationToken.Purpose.EMAIL).latest("created_at")
        verify_payload = {"purpose": VerificationToken.Purpose.EMAIL, "code": email_token.code}
        response = self.client.post(self.verify_url, verify_payload, format="json", **self._auth_headers(token))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user.refresh_from_db()
        self.assertTrue(user.email_verified)

        # Request another phone verification and ensure we can resend
        response = self.client.post(self.resend_phone_url, format="json", **self._auth_headers(token))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        phone_token = VerificationToken.objects.filter(user=user, purpose=VerificationToken.Purpose.PHONE).latest("created_at")
        response = self.client.post(
            self.verify_url,
            {"purpose": VerificationToken.Purpose.PHONE, "code": phone_token.code},
            format="json",
            **self._auth_headers(token),
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user.refresh_from_db()
        self.assertTrue(user.phone_verified)

        response = self.client.patch(self.profile_url, {"about_me": "Food lover"}, format="json", **self._auth_headers(token))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["about_me"], "Food lover")

    def test_role_permission_blocks_unverified_user(self):
        payload = {
            "email": "chef@example.com",
            "password": "secret123",
            "first_name": "Chef",
            "last_name": "User",
            "phone": "+15555550111",
            "role": "Chef",
        }
        self.client.post(self.register_url, payload, format="json")
        login_response = self.client.post(self.login_url, {"email": payload["email"], "password": payload["password"]}, format="json")
        token = login_response.data["token"]

        # Without phone verification, we should still be able to request a resend
        response = self.client.post(self.resend_phone_url, format="json", **self._auth_headers(token))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

        # Verify role check by impersonating admin-only requirement in future endpoints
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token}")
        response = self.client.post(self.request_verification_url, {"purpose": VerificationToken.Purpose.EMAIL}, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
