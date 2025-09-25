from django.db.models import Q
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.authentication import TokenAuthentication
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from chats.api.serializers import (
    CreateOrderMessageSerializer,
    MessageTemplateSerializer,
    OrderChatThreadSerializer,
    OrderMessageSerializer,
)
from chats.models import MessageTemplate, OrderChatThread


def _get_order_thread_for_user(order_id, user):
    queryset = OrderChatThread.objects.select_related("order").prefetch_related(
        "thread_participants__user",
        "messages__sender",
        "messages__template",
    )
    filters = Q(order__order_id=order_id)
    if str(order_id).isdigit():
        filters = filters | Q(order__pk=int(order_id))
    thread = get_object_or_404(queryset, filters)
    if not thread.thread_participants.filter(user=user, is_active=True).exists():
        return None
    return thread


@api_view(["GET"])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def get_order_thread_view(request, order_id):
    thread = _get_order_thread_for_user(order_id, request.user)
    if thread is None:
        return Response({"detail": "You do not have access to this order chat."}, status=status.HTTP_403_FORBIDDEN)
    serializer = OrderChatThreadSerializer(thread)
    return Response(serializer.data)


@api_view(["GET"])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def list_thread_messages_view(request, order_id):
    thread = _get_order_thread_for_user(order_id, request.user)
    if thread is None:
        return Response({"detail": "You do not have access to this order chat."}, status=status.HTTP_403_FORBIDDEN)

    messages = thread.messages.select_related("sender", "template").all()
    serializer = OrderMessageSerializer(messages, many=True)
    return Response(serializer.data)


@api_view(["POST"])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def post_thread_message_view(request, order_id):
    thread = _get_order_thread_for_user(order_id, request.user)
    if thread is None:
        return Response({"detail": "You do not have access to this order chat."}, status=status.HTTP_403_FORBIDDEN)

    serializer = CreateOrderMessageSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    message = thread.record_message(
        sender=request.user,
        body=serializer.validated_data["body"],
        template=serializer.validated_data.get("template"),
        metadata=serializer.validated_data.get("metadata") or {},
    )
    output = OrderMessageSerializer(message)
    return Response(output.data, status=status.HTTP_201_CREATED)


@api_view(["GET"])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def list_message_templates_view(request):
    audience = request.query_params.get("audience")
    queryset = MessageTemplate.objects.all()
    if audience:
        queryset = queryset.filter(audience__in=[audience, MessageTemplate.Audience.UNIVERSAL])
    serializer = MessageTemplateSerializer(queryset, many=True)
    return Response(serializer.data)
