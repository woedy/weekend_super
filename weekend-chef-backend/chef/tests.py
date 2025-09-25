from django.urls import reverse
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from accounts.models import User
from food.models import FoodCategory, Dish, DishIngredient, CustomizationOption, FoodCustomization

from chef.models import ChefDocument, ChefProfile


class ChefProfileAPITests(APITestCase):
    def setUp(self):
        self.register_url = reverse("accounts_api:register")
        self.login_url = reverse("accounts_api:login")
        self.profile_list_url = reverse("chef:v2:chef-profile-list")
        category = FoodCategory.objects.create(name="Stews")
        self.dish = Dish.objects.create(name="Jollof", category=category, description="Spicy rice")
        DishIngredient.objects.create(dish=self.dish, name="Rice", description="", quantity=1, unit="kg", price=10)
        option = CustomizationOption.objects.create(option_type="Spice", name="Spice Level", price=0)
        FoodCustomization.objects.create(food_item=self.dish, custom_option=option)
        
    def _auth_headers(self, token_key: str):
        return {"HTTP_AUTHORIZATION": f"Token {token_key}"}

    def _register_and_login_chef(self):
        payload = {
            "email": "chef@app.com",
            "password": "secret123",
            "first_name": "Chef",
            "last_name": "Example",
            "phone": "+15555550000",
            "role": "Chef",
        }
        self.client.post(self.register_url, payload, format="json")
        login = self.client.post(self.login_url, {"email": payload["email"], "password": payload["password"]}, format="json")
        return login.data["token"], User.objects.get(email=payload["email"])

    def test_chef_profile_creation_and_document_upload(self):
        token, user = self._register_and_login_chef()
        profile_data = {
            "chef_type": "Home Chef",
            "kitchen_address": "123 Campus Ave",
            "availability": "Both",
            "service_radius": 15,
        }
        response = self.client.post(self.profile_list_url, profile_data, format="json", **self._auth_headers(token))
        self.assertIn(response.status_code, (status.HTTP_201_CREATED, status.HTTP_200_OK))
        profile = ChefProfile.objects.get(user=user)
        self.assertEqual(profile.kitchen_address, "123 Campus Ave")

        document_url = reverse("chef:v2:chef-profile-documents", args=[profile.pk])
        upload = SimpleUploadedFile("certificate.pdf", b"fake-cert", content_type="application/pdf")
        response = self.client.post(document_url, {"document_type": "certification", "file": upload}, **self._auth_headers(token))
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(ChefDocument.objects.filter(profile=profile).count(), 1)

    def test_admin_can_review_profile(self):
        token, user = self._register_and_login_chef()
        self.client.post(self.profile_list_url, {"chef_type": "Home Chef"}, format="json", **self._auth_headers(token))
        profile = ChefProfile.objects.get(user=user)

        admin = User.objects.create_superuser(email="admin@app.com", password="pass123", first_name="Admin", last_name="User")
        admin.user_type = "Admin"
        admin.save()
        admin_token = Token.objects.get(user=admin)
        review_url = reverse("chef:v2:chef-profile-review", args=[profile.pk])
        response = self.client.patch(review_url, {"review_status": "approved", "review_notes": "Looks good"}, format="json", **self._auth_headers(admin_token.key))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        profile.refresh_from_db()
        self.assertEqual(profile.review_status, ChefProfile.ReviewStatus.APPROVED)
        self.assertTrue(profile.reviewed_at)

    def test_menu_item_versioning_and_grocery_estimate(self):
        token, user = self._register_and_login_chef()
        self.client.post(self.profile_list_url, {"chef_type": "Home Chef"}, format="json", **self._auth_headers(token))
        menu_url = reverse("chef:v2:menu-item-list")
        payload = {
            "dish": self.dish.pk,
            "small_price": "25.00",
            "small_value": "Feeds 1",
            "active": True,
        }
        response = self.client.post(menu_url, payload, format="json", **self._auth_headers(token))
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        menu_item_id = response.data["id"]
        detail_url = reverse("chef:v2:menu-item-detail", args=[menu_item_id])
        response = self.client.get(detail_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["grocery_budget_estimate"], "10.00")
        self.assertEqual(response.data["menu_version"], 1)

        update_response = self.client.patch(detail_url, {"small_price": "27.00"}, format="json", **self._auth_headers(token))
        self.assertEqual(update_response.status_code, status.HTTP_200_OK)
        response = self.client.get(detail_url)
        self.assertEqual(response.data["menu_version"], 2)
        self.assertEqual(len(response.data["versions"]), 2)
