from django.apps import apps
from django.db.models.signals import post_save
from django.dispatch import receiver

from chats.models import OrderChatThread, OrderMessage


@receiver(post_save, sender=OrderMessage)
def trigger_message_notifications(sender, instance, created, **kwargs):
    if created:
        instance.notify_participants()


Order = apps.get_model("orders", "Order")


@receiver(post_save, sender=Order)
def ensure_thread_for_order(sender, instance, **kwargs):
    thread, _ = OrderChatThread.objects.get_or_create(order=instance)
    thread.sync_participants()
