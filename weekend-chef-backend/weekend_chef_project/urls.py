"""
URL configuration for weekend_chef_project project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.conf import settings
from django.contrib import admin
from django.urls import include, path
from django.views.generic import TemplateView
from django.conf.urls.static import static

from . import qa_views


urlpatterns = [
    path('admin/', admin.site.urls),
    path('support/faq/', TemplateView.as_view(template_name='support/faq.html'), name='support_faq'),
    path('api/accounts/', include('accounts.api.urls', 'accounts_api')),
    path('api/food/', include('food.api.urls', 'food_api')),
    path('api/orders/', include('orders.api.urls', 'orders_api')),
    path('api/homepage/', include('homepage.api.urls', 'homepage_api')),
    path('api/clients/', include('clients.api.urls', 'clients_api')),
    path('api/complaints/', include('complaints.api.urls', 'complaints_api')),
    path('api/chef/', include('chef.api.urls', 'chef_api')),
    path('api/notifications/', include('notifications.api.urls', 'notifications_api')),
    path('api/chats/', include('chats.api.urls', 'chats_api')),
    path('api/qa/order-smoke/', qa_views.order_smoke_test, name='qa_order_smoke'),
]

if settings.DEBUG:
    urlpatterns = urlpatterns + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns = urlpatterns + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

