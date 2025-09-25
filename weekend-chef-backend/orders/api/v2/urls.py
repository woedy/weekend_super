from rest_framework.routers import DefaultRouter

from orders.api.v2.views import OrderViewSet

app_name = 'v2'

router = DefaultRouter()
router.register(r'orders', OrderViewSet, basename='order')

urlpatterns = router.urls
