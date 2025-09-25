from django.contrib.auth import get_user_model
from rest_framework import serializers

from chats.models import MessageTemplate, OrderChatThread, OrderMessage, ThreadParticipant


User = get_user_model()


class UserSummarySerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["user_id", "first_name", "last_name", "email", "user_type", "photo"]


class ThreadParticipantSerializer(serializers.ModelSerializer):
    user = UserSummarySerializer(read_only=True)

    class Meta:
        model = ThreadParticipant
        fields = ["id", "role", "is_active", "joined_at", "updated_at", "user"]


class MessageTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = MessageTemplate
        fields = ["id", "key", "label", "body", "audience"]


class OrderMessageSerializer(serializers.ModelSerializer):
    sender = UserSummarySerializer(read_only=True)
    template = MessageTemplateSerializer(read_only=True)

    class Meta:
        model = OrderMessage
        fields = ["id", "body", "created_at", "metadata", "sender", "template"]


class CreateOrderMessageSerializer(serializers.ModelSerializer):
    template_key = serializers.SlugField(required=False, allow_null=True)

    class Meta:
        model = OrderMessage
        fields = ["body", "template_key", "metadata"]

    def validate(self, attrs):
        template_key = attrs.pop("template_key", None)
        if template_key:
            try:
                template = MessageTemplate.objects.get(key=template_key)
            except MessageTemplate.DoesNotExist as exc:
                raise serializers.ValidationError({"template_key": "Unknown template."}) from exc
            attrs["template"] = template
        return attrs


class OrderChatThreadSerializer(serializers.ModelSerializer):
    participants = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    order_reference = serializers.SerializerMethodField()

    class Meta:
        model = OrderChatThread
        fields = ["id", "order", "order_reference", "participants", "created_at", "updated_at", "last_message"]
        read_only_fields = ["id", "order", "created_at", "updated_at", "last_message", "order_reference"]

    def get_last_message(self, obj):
        message = obj.messages.select_related("sender", "template").order_by("-created_at").first()
        if not message:
            return None
        return OrderMessageSerializer(message).data

    def get_order_reference(self, obj):
        return obj.order.order_id or str(obj.order.pk)

    def get_participants(self, obj):
        participants = obj.thread_participants.select_related("user").order_by("joined_at")
        return ThreadParticipantSerializer(participants, many=True).data
