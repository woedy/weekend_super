import os
import random

from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import models
from django.utils import timezone

from notifications.models import Notification, NotificationPreference



def get_filename_ext(filepath):
    base_name = os.path.basename(filepath)
    name, ext = os.path.splitext(base_name)
    return name, ext


def upload_message_image_path(instance, filename):
    new_filename = random.randint(1, 3910209312)
    name, ext = get_filename_ext(filename)
    final_filename = '{new_filename}{ext}'.format(new_filename=new_filename, ext=ext)
    return "messages/{final_filename}".format(
        new_filename=new_filename,
        final_filename=final_filename
    )


class PrivateChatRoom(models.Model):
    room_id = models.CharField(max_length=255, blank=True, null=True, unique=True)
    shop = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="shop_chats",
        null=True,
        blank=True,
    )
    client = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="client_chats",
        null=True,
        blank=True,
    )

    connected_users = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        blank=True,
        related_name="connected_users",
    )
    is_active = models.BooleanField(default=False)

    def connect_user(self, user):
        is_user_added = False
        if not user is self.connected_users.all():
            self.connected_users.add(user)
            is_user_added = True
        return is_user_added

    def disconnect_user(self, user):
        is_user_removed = False
        if user in self.connected_users.all():
            is_user_removed = True
        return is_user_removed

    @property
    def group_name(self):
        return f"Room-{self.room_id}"


#def pre_save_room_id_receiver(sender, instance, *args, **kwargs):
#    if not instance.room_id:
#        instance.room_id = unique_room_id_generator(instance)
#
#pre_save.connect(pre_save_room_id_receiver, sender=PrivateChatRoom)




class RoomChatMessageManager(models.Manager):
    def by_room(self, room):
        qs = PrivateRoomChatMessage.objects.filter(room=room).order_by("-timestamp")
        return qs


class PrivateRoomChatMessage(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='user_messages')
    room = models.ForeignKey(PrivateChatRoom, on_delete=models.CASCADE, related_name="private_chat_room_messages")
    timestamp = models.DateTimeField(auto_now_add=True)
    message = models.TextField(unique=False, blank=False)
    read = models.BooleanField(default=False)


    objects = RoomChatMessageManager()

    def __str__(self):
        return self.message



class PrivateRoomChatImage(models.Model):
    message = models.ForeignKey(PrivateRoomChatMessage, on_delete=models.CASCADE, related_name="private_chat_room_message")
    image = models.ImageField(upload_to=upload_message_image_path, null=True, blank=True)


class MessageTemplate(models.Model):
    class Audience(models.TextChoices):
        CLIENT = "client", "Client"
        CHEF = "chef", "Chef"
        DISPATCH = "dispatch", "Dispatch"
        UNIVERSAL = "universal", "All Participants"

    key = models.SlugField(unique=True)
    label = models.CharField(max_length=200)
    body = models.TextField()
    audience = models.CharField(
        max_length=20,
        choices=Audience.choices,
        default=Audience.UNIVERSAL,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["label"]

    def __str__(self) -> str:
        return f"{self.label} ({self.audience})"


class OrderChatThread(models.Model):
    class Role(models.TextChoices):
        CLIENT = "client", "Client"
        CHEF = "chef", "Chef"
        DISPATCH = "dispatch", "Dispatch"
        ADMIN = "admin", "Admin"

    order = models.OneToOneField(
        "orders.Order",
        on_delete=models.CASCADE,
        related_name="chat_thread",
    )
    participants = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        through="ThreadParticipant",
        related_name="order_chat_threads",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        identifier = self.order.order_id or self.order.pk
        return f"Thread for order {identifier}"

    def add_participant(self, user, role):
        participant, created = ThreadParticipant.objects.get_or_create(
            thread=self,
            user=user,
            defaults={"role": role},
        )
        if not created and participant.role != role:
            participant.role = role
            participant.save(update_fields=["role", "updated_at"])
        if not participant.is_active:
            participant.is_active = True
            participant.save(update_fields=["is_active", "updated_at"])
        return participant

    def sync_participants(self):
        from orders.models import Order

        # Ensure the related order object is refreshed to pick up latest assignments
        order = Order.objects.select_related(
            "client__user",
            "chef__user",
            "dispatch__user",
        ).get(pk=self.order.pk)

        participant_map = []
        if order.client and order.client.user:
            participant_map.append((order.client.user, OrderChatThread.Role.CLIENT))
        if order.chef and order.chef.user:
            participant_map.append((order.chef.user, OrderChatThread.Role.CHEF))
        if order.dispatch and order.dispatch.user:
            participant_map.append((order.dispatch.user, OrderChatThread.Role.DISPATCH))

        for user, role in participant_map:
            self.add_participant(user, role)

        # mark inactive participants who are no longer attached to the order
        current_user_ids = {user.pk for user, _ in participant_map}
        ThreadParticipant.objects.filter(thread=self).exclude(user_id__in=current_user_ids).exclude(
            role=OrderChatThread.Role.ADMIN,
        ).update(
            is_active=False,
            updated_at=timezone.now(),
        )

    def record_message(self, sender, body, template=None, metadata=None):
        message = OrderMessage.objects.create(
            thread=self,
            sender=sender,
            body=body,
            template=template,
            metadata=metadata or {},
        )
        self.updated_at = timezone.now()
        self.save(update_fields=["updated_at"])
        return message


class ThreadParticipant(models.Model):
    thread = models.ForeignKey(OrderChatThread, on_delete=models.CASCADE, related_name="thread_participants")
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="chat_participation")
    role = models.CharField(max_length=20, choices=OrderChatThread.Role.choices)
    is_active = models.BooleanField(default=True)
    joined_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("thread", "user")

    def __str__(self) -> str:
        return f"{self.user.email} in {self.thread}"


class OrderMessage(models.Model):
    thread = models.ForeignKey(OrderChatThread, on_delete=models.CASCADE, related_name="messages")
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="order_messages")
    body = models.TextField()
    template = models.ForeignKey(
        MessageTemplate,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="messages",
    )
    metadata = models.JSONField(default=dict, blank=True)
    read_by = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name="read_order_messages", blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]

    def __str__(self) -> str:
        preview = self.body if len(self.body) <= 20 else f"{self.body[:17]}..."
        return f"Message by {self.sender.email}: {preview}"

    def notify_participants(self):
        participant_ids = self.thread.participants.exclude(pk=self.sender_id).values_list("id", flat=True)
        users = get_user_model().objects.filter(id__in=participant_ids)
        order_reference = self.thread.order.order_id or self.thread.order.pk
        for user in users:
            try:
                preferences = user.notification_preferences
                if not preferences.push_updates:
                    continue
            except NotificationPreference.DoesNotExist:
                preferences = None
            Notification.objects.create(
                user=user,
                title=f"New message for order {order_reference}",
                subject=self.body,
            )



