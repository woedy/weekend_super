from django.contrib.auth import get_user_model
from django.db import models

User = get_user_model()




class Notification(models.Model):
    title = models.CharField(max_length=1000, null=True, blank=True)
    subject = models.TextField(null=True, blank=True)
    read = models.BooleanField(default=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="notifications")


    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)



class NotificationPreference(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="notification_preferences")
    email_updates = models.BooleanField(default=True)
    push_updates = models.BooleanField(default=True)
    sms_updates = models.BooleanField(default=False)
    order_status_updates = models.BooleanField(default=True)

    def __str__(self):
        return f"Preferences for {self.user.email}"
