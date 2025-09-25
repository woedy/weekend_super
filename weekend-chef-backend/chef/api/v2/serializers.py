from __future__ import annotations

from django.contrib.auth import get_user_model
from rest_framework import serializers

from accounts.api.v2.serializers import ProfileSerializer
from food.models import CustomizationOption, Dish, DishIngredient

from chef.models import ChefDocument, ChefProfile, Certification, CuisineSpecialty, ChefDish, MenuItemVersion

User = get_user_model()


class ChefDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChefDocument
        fields = ["id", "document_type", "file", "description", "uploaded_at"]
        read_only_fields = ["id", "uploaded_at"]


class ChefProfileSerializer(serializers.ModelSerializer):
    user = ProfileSerializer(read_only=True)
    certifications = serializers.PrimaryKeyRelatedField(queryset=Certification.objects.all(), many=True, required=False)
    cuisine_specialties = serializers.PrimaryKeyRelatedField(queryset=CuisineSpecialty.objects.all(), many=True, required=False)
    documents = ChefDocumentSerializer(many=True, read_only=True)

    class Meta:
        model = ChefProfile
        fields = [
            "id",
            "chef_id",
            "user",
            "chef_type",
            "certifications",
            "kitchen_address",
            "kitchen_location",
            "lat",
            "lng",
            "service_radius",
            "availability",
            "cuisine_specialties",
            "years_of_experience",
            "max_order_capacity",
            "total_orders",
            "average_rating",
            "active",
            "review_status",
            "review_notes",
            "reviewed_at",
            "documents",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "chef_id",
            "total_orders",
            "average_rating",
            "reviewed_at",
            "created_at",
            "updated_at",
        ]

    def update(self, instance, validated_data):
        certifications = validated_data.pop("certifications", None)
        specialties = validated_data.pop("cuisine_specialties", None)
        user = self.context["request"].user
        if user.user_type != "Admin":
            validated_data.pop("review_status", None)
            validated_data.pop("review_notes", None)
        instance = super().update(instance, validated_data)
        if certifications is not None:
            instance.certifications.set(certifications)
        if specialties is not None:
            instance.cuisine_specialties.set(specialties)
        return instance


class ChefDocumentUploadSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChefDocument
        fields = ["id", "document_type", "file", "description"]
        read_only_fields = ["id"]

    def create(self, validated_data):
        profile = self.context["profile"]
        return ChefDocument.objects.create(profile=profile, **validated_data)


class CustomizationOptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomizationOption
        fields = ["id", "option_type", "name", "description", "price", "unit", "value"]


class DishIngredientSerializer(serializers.ModelSerializer):
    class Meta:
        model = DishIngredient
        fields = ["id", "name", "quantity", "unit", "price"]


class MenuItemVersionSerializer(serializers.ModelSerializer):
    class Meta:
        model = MenuItemVersion
        fields = ["version", "snapshot", "created_at"]


class ChefMenuItemSerializer(serializers.ModelSerializer):
    dish = serializers.PrimaryKeyRelatedField(queryset=Dish.objects.all())
    options = serializers.SerializerMethodField()
    ingredients = serializers.SerializerMethodField()
    versions = MenuItemVersionSerializer(many=True, read_only=True)

    class Meta:
        model = ChefDish
        fields = [
            "id",
            "dish",
            "small_price",
            "small_value",
            "medium_price",
            "medium_value",
            "large_price",
            "large_value",
            "grocery_budget_estimate",
            "menu_version",
            "active",
            "options",
            "ingredients",
            "versions",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["grocery_budget_estimate", "menu_version", "versions", "created_at", "updated_at"]

    def validate(self, attrs):
        if not any([
            attrs.get("small_price"),
            attrs.get("medium_price"),
            attrs.get("large_price"),
        ]):
            raise serializers.ValidationError("At least one portion price must be provided.")
        return attrs

    def get_options(self, obj):
        customization_options = CustomizationOption.objects.filter(custom_options__food_item=obj.dish).distinct()
        return CustomizationOptionSerializer(customization_options, many=True).data

    def get_ingredients(self, obj):
        return DishIngredientSerializer(obj.dish.ingredients.all(), many=True).data
