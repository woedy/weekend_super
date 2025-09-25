from rest_framework import serializers

from complaints.models import DisputeTicket
from orders.models import Order
from orders.services import apply_payout_adjustment


class DisputeTicketSerializer(serializers.ModelSerializer):
    order = serializers.PrimaryKeyRelatedField(queryset=Order.objects.all())

    class Meta:
        model = DisputeTicket
        fields = ["id", "order", "description", "status", "resolution_notes", "payout_adjustment", "created_at", "updated_at"]
        read_only_fields = ["status", "resolution_notes", "payout_adjustment", "created_at", "updated_at"]

    def create(self, validated_data):
        user = self.context["user"]
        order = validated_data["order"]
        if order.client.user != user:
            raise serializers.ValidationError({"order": "You can only dispute your own orders."})
        validated_data["raised_by"] = user
        return DisputeTicket.objects.create(**validated_data)


class DisputeResolutionSerializer(serializers.ModelSerializer):
    class Meta:
        model = DisputeTicket
        fields = ["status", "resolution_notes", "payout_adjustment"]

    def update(self, instance, validated_data):
        payout_adjustment = validated_data.get("payout_adjustment")
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if payout_adjustment:
            apply_payout_adjustment(instance.order, payout_adjustment)
        return instance
