from rest_framework import serializers

from clients.models import Allergy
from orders.models import CustomizationValue, Order, OrderAllergenReport, OrderItem, OrderStatus

class CustomizationValueSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomizationValue
        fields = ['customization_option', 'quantity']

class OrderItemSerializer(serializers.ModelSerializer):

    class Meta:
        model = OrderItem
        fields = ['cart_item', 'quantity', 'total_price']

        
class ChefOrderItemSerializer(serializers.ModelSerializer):

    class Meta:
        model = OrderItem
        fields = ['cart_item', 'quantity', 'total_price']

class OrderStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderStatus
        fields = ['status', 'created_at']

class OrderAllergenReportSerializer(serializers.ModelSerializer):
    allergies = serializers.PrimaryKeyRelatedField(read_only=True, many=True)

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
        ]


class OrderSerializer(serializers.ModelSerializer):
    order_statuses = OrderStatusSerializer(many=True)  # Include the order status history
    allergen_report = OrderAllergenReportSerializer(read_only=True)

    class Meta:
        model = Order
        fields = ['order_id', 'client', 'total_price', 'order_date', 'order_time', 'order_statuses', 'allergen_report']




class ChefOrderSerializer(serializers.ModelSerializer):
    order_statuses = OrderStatusSerializer(many=True)  # Include the order status history

    class Meta:
        model = Order
        fields = ['order_id', 'client', 'total_price', 'order_date', 'order_time', 'order_statuses']

