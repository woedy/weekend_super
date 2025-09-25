from rest_framework.routers import DefaultRouter

from complaints.api.v2.views import DisputeTicketViewSet

app_name = 'v2'

router = DefaultRouter()
router.register(r'disputes', DisputeTicketViewSet, basename='dispute')

urlpatterns = router.urls
