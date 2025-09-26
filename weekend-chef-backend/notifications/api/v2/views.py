from rest_framework import generics
from rest_framework.permissions import IsAuthenticated

from accounts.api.custom_jwt import CustomJWTAuthentication
from rest_framework.authentication import TokenAuthentication
from notifications.api.v2.serializers import NotificationPreferenceSerializer
from notifications.models import NotificationPreference


class NotificationPreferenceView(generics.RetrieveUpdateAPIView):
    serializer_class = NotificationPreferenceSerializer
    permission_classes = [IsAuthenticated]
    authentication_classes = [CustomJWTAuthentication, TokenAuthentication]

    def get_object(self):
        preference, _ = NotificationPreference.objects.get_or_create(user=self.request.user)
        return preference
