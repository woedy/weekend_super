from rest_framework.routers import DefaultRouter

from chef.api.v2.views import ChefDocumentViewSet, ChefProfileViewSet, ChefMenuItemViewSet

app_name = 'v2'

router = DefaultRouter()
router.register(r'profiles', ChefProfileViewSet, basename='chef-profile')
router.register(r'documents', ChefDocumentViewSet, basename='chef-document')
router.register(r'menu-items', ChefMenuItemViewSet, basename='menu-item')

urlpatterns = router.urls
