from __future__ import annotations

from decimal import Decimal

from django.core.exceptions import ValidationError as DjangoValidationError
from rest_framework import serializers

from chef.models import ChefProfile
from orders.models import CartItem, DeliveryProof, EscrowLedgerEntry, Order, OrderRating, OrderStatusTransition
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


class OrderSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(source="cart.items", many=True, read_only=True)
    chef = serializers.PrimaryKeyRelatedField(queryset=ChefProfile.objects.all())
    escrow_entries = EscrowEntrySerializer(many=True, read_only=True)
    status_transitions = OrderStatusTransitionSerializer(many=True, read_only=True)

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
