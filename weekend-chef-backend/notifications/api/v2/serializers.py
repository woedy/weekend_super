from django.utils import timezone
from rest_framework import serializers

from notifications.models import NotificationPreference


class NotificationPreferenceSerializer(serializers.ModelSerializer):
    consent_updated_at = serializers.DateTimeField(read_only=True)

    class Meta:
        model = NotificationPreference
        fields = [
            "email_updates",
            "push_updates",
            "sms_updates",
            "order_status_updates",
            "marketing_updates",
            "consent_version",
            "consent_source",
            "consent_updated_at",
        ]

    def update(self, instance, validated_data):
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        # Always refresh the consent timestamp when preferences change
        instance.consent_updated_at = timezone.now()
        instance.save(update_fields=[
            "email_updates",
            "push_updates",
            "sms_updates",
            "order_status_updates",
            "marketing_updates",
            "consent_version",
            "consent_source",
            "consent_updated_at",
        ])
        return instance
