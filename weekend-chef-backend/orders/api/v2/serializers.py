from __future__ import annotations

from decimal import Decimal

from decimal import Decimal

from django.core.exceptions import ValidationError as DjangoValidationError
from django.utils import timezone
from rest_framework import serializers

from chef.models import ChefProfile
from clients.models import Allergy
from orders.models import (
    CartItem,
    DeliveryProof,
    EscrowLedgerEntry,
    Order,
    OrderAllergenReport,
    OrderRating,
    OrderStatusTransition,
)
from orders.services import create_order_with_split, transition_order


class CartItemSerializer(serializers.ModelSerializer):
    total_price = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = ["id", "dish", "quantity", "package", "package_price", "total_price"]
        read_only_fields = ["id", "total_price"]

    def get_total_price(self, obj):
        return obj.total_price()


class EscrowEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = EscrowLedgerEntry
        fields = ["entry_type", "amount", "reference", "processed_at"]


class OrderStatusTransitionSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderStatusTransition
        fields = ["status", "changed_at", "notes"]


class OrderAllergenReportSerializer(serializers.ModelSerializer):
    allergies = serializers.PrimaryKeyRelatedField(read_only=True, many=True)
    allergy_labels = serializers.SerializerMethodField()

    class Meta:
        model = OrderAllergenReport
        fields = [
            "reported_by_client",
            "reported_at",
            "acknowledged_by_chef",
            "acknowledged_at",
            "custom_allergy_notes",
            "acknowledgement_notes",
            "allergies",
            "allergy_labels",
        ]
        read_only_fields = [
            "reported_by_client",
            "reported_at",
            "acknowledged_by_chef",
            "acknowledged_at",
            "allergy_labels",
        ]

    def get_allergy_labels(self, obj):
        return [allergy.name for allergy in obj.allergies.all()]


class OrderAllergenSubmissionSerializer(serializers.ModelSerializer):
    allergies = serializers.PrimaryKeyRelatedField(queryset=Allergy.objects.all(), many=True, required=False)

    class Meta:
        model = OrderAllergenReport
        fields = ["allergies", "custom_allergy_notes"]

    def update(self, instance, validated_data):
        allergies = validated_data.pop("allergies", None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.reported_by_client = True
        instance.reported_at = timezone.now()
        instance.acknowledged_by_chef = False
        instance.acknowledged_at = None
        instance.acknowledgement_notes = ""
        instance.save()
        if allergies is not None:
            instance.allergies.set(allergies)
        return instance


class OrderAllergenAcknowledgementSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderAllergenReport
        fields = ["acknowledgement_notes"]

    def update(self, instance, validated_data):
        instance.acknowledgement_notes = validated_data.get("acknowledgement_notes", "")
        instance.acknowledged_by_chef = True
        instance.acknowledged_at = timezone.now()
        instance.save(update_fields=["acknowledgement_notes", "acknowledged_by_chef", "acknowledged_at"])
        return instance


class OrderSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(source="cart.items", many=True, read_only=True)
    chef = serializers.PrimaryKeyRelatedField(queryset=ChefProfile.objects.all())
    escrow_entries = EscrowEntrySerializer(many=True, read_only=True)
    status_transitions = OrderStatusTransitionSerializer(many=True, read_only=True)
    allergen_report = OrderAllergenReportSerializer(read_only=True)

    class Meta:
        model = Order
        fields = [
            "id",
            "order_id",
            "cart",
            "chef",
            "client",
            "status",
            "total_price",
            "grocery_advance_amount",
            "final_payout_amount",
            "platform_fee_amount",
            "delivery_window_start",
            "delivery_window_end",
            "delivery_fee",
            "tax",
            "location",
            "fast_order",
            "items",
            "escrow_entries",
            "status_transitions",
            "allergen_report",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "order_id",
            "client",
            "status",
            "total_price",
            "grocery_advance_amount",
            "final_payout_amount",
            "platform_fee_amount",
            "escrow_entries",
            "status_transitions",
            "created_at",
            "updated_at",
            "items",
            "allergen_report",
        ]

    def create(self, validated_data):
        cart = validated_data.get("cart")
        if not cart:
            raise serializers.ValidationError({"cart": "Cart is required"})
        total = Decimal("0")
        for item in cart.items.all():
            total += item.total_price()
        validated_data["total_price"] = total
        order = Order(**validated_data)
        try:
            return create_order_with_split(order)
        except DjangoValidationError as exc:
            detail = exc.message_dict if hasattr(exc, "message_dict") and exc.message_dict else exc.messages
            raise serializers.ValidationError(detail)


class OrderStatusSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=Order.Status.choices)
    notes = serializers.CharField(required=False, allow_blank=True)

    def save(self, **kwargs):
        order = self.context["order"]
        user = self.context.get("user")
        result = transition_order(order, self.validated_data["status"], changed_by=user, notes=self.validated_data.get("notes", ""))
        return result.order


class DeliveryProofSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeliveryProof
        fields = ["photo", "signature"]

    def create(self, validated_data):
        order = self.context["order"]
        dispatcher = self.context["dispatcher"]
        proof, _ = DeliveryProof.objects.update_or_create(order=order, defaults={**validated_data, "submitted_by": dispatcher})
        transition_order(order, Order.Status.DELIVERED, changed_by=None)
        return proof


class OrderRatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderRating
        fields = ["rating", "report"]

    def validate(self, attrs):
        order = self.context["order"]
        if order.status not in [Order.Status.DELIVERED, Order.Status.COMPLETED]:
            raise serializers.ValidationError("Order must be delivered before rating.")
        return attrs

    def create(self, validated_data):
        order = self.context["order"]
        rating, _ = OrderRating.objects.update_or_create(order=order, defaults=validated_data)
        return rating
