"""
ASGI config for weekend_chef_project project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/howto/deployment/asgi/
"""

import os

from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application

from weekend_chef_project.routing import websocket_urlpatterns

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'weekend_chef_project.settings')

dj_application = get_asgi_application()

application = ProtocolTypeRouter({
    "http": dj_application,
    "websocket": AuthMiddlewareStack(URLRouter(websocket_urlpatterns)),
})
