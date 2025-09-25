from django.urls import path

from notifications.api.v2.views import NotificationPreferenceView

app_name = 'v2'

urlpatterns = [
    path('preferences/', NotificationPreferenceView.as_view(), name='preferences'),
]
