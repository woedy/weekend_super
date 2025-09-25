from django.urls import path

from chats.api.views import (
    get_order_thread_view,
    list_message_templates_view,
    list_thread_messages_view,
    post_thread_message_view,
)

app_name = "chats"

urlpatterns = [
    path("order-threads/<str:order_id>/", get_order_thread_view, name="order_thread"),
    path("order-threads/<str:order_id>/messages/", list_thread_messages_view, name="order_thread_messages"),
    path("order-threads/<str:order_id>/messages/send/", post_thread_message_view, name="send_order_thread_message"),
    path("message-templates/", list_message_templates_view, name="message_templates"),
]
