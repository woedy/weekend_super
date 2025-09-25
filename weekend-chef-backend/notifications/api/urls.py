from django.urls import include, path

from notifications.api.views import set_notification_to_read, get_all_notifications, delete_notification

app_name = 'notifications'

urlpatterns = [
    path('set-to-read/', set_notification_to_read, name="set_notification_to_read"),
    path('get-all-notifications/', get_all_notifications, name="get_all_notifications"),
    path('delete-notification/', delete_notification, name="delete_notification"),
    path('v2/', include(('notifications.api.v2.urls', 'v2'), namespace='v2')),
]
