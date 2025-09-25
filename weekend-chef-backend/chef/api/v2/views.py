from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from accounts.api.permissions import RolePermission
from chef.api.v2.serializers import (
    ChefDocumentSerializer,
    ChefDocumentUploadSerializer,
    ChefMenuItemSerializer,
    ChefProfileSerializer,
)
from chef.models import ChefDocument, ChefProfile, ChefDish


class ChefProfileViewSet(viewsets.ModelViewSet):
    serializer_class = ChefProfileSerializer
    permission_classes = [IsAuthenticated, RolePermission]
    required_roles = ["Chef", "Admin"]

    def get_permissions(self):
        if getattr(self, "action", None) == "review":
            self.required_roles = ["Admin"]
        else:
            self.required_roles = ["Chef", "Admin"]
        return super().get_permissions()

    def get_queryset(self):
        user = self.request.user
        queryset = ChefProfile.objects.select_related("user").prefetch_related("certifications", "cuisine_specialties", "documents")
        if user.user_type == "Admin":
            return queryset
        return queryset.filter(user=user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def create(self, request, *args, **kwargs):
        if request.user.user_type != "Chef":
            return Response({"detail": "Only chefs can create profiles."}, status=status.HTTP_403_FORBIDDEN)
        if ChefProfile.objects.filter(user=request.user).exists():
            profile = ChefProfile.objects.get(user=request.user)
            serializer = self.get_serializer(profile)
            return Response(serializer.data, status=status.HTTP_200_OK)
        return super().create(request, *args, **kwargs)

    @action(detail=True, methods=["post"], serializer_class=ChefDocumentUploadSerializer)
    def documents(self, request, pk=None):
        profile = self.get_object()
        if request.user.user_type != "Admin" and profile.user != request.user:
            return Response(status=status.HTTP_403_FORBIDDEN)
        serializer = self.get_serializer(data=request.data, context={"profile": profile})
        serializer.is_valid(raise_exception=True)
        document = serializer.save()
        return Response(ChefDocumentSerializer(document, context=self.get_serializer_context()).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["patch"], permission_classes=[IsAuthenticated, RolePermission], url_path="review")
    def review(self, request, pk=None):
        self.required_roles = ["Admin"]
        profile = self.get_object()
        status_value = request.data.get("review_status")
        if status_value not in dict(ChefProfile.ReviewStatus.choices):
            return Response({"review_status": "Invalid status."}, status=status.HTTP_400_BAD_REQUEST)
        profile.review_status = status_value
        profile.review_notes = request.data.get("review_notes", profile.review_notes)
        profile.save()
        return Response(self.get_serializer(profile).data)


class ChefDocumentViewSet(mixins.DestroyModelMixin, viewsets.GenericViewSet):
    serializer_class = ChefDocumentSerializer
    permission_classes = [IsAuthenticated, RolePermission]
    required_roles = ["Chef", "Admin"]
    queryset = ChefDocument.objects.all()

    def get_queryset(self):
        qs = super().get_queryset()
        user = self.request.user
        if user.user_type == "Admin":
            return qs
        return qs.filter(profile__user=user)


class ChefMenuItemViewSet(viewsets.ModelViewSet):
    serializer_class = ChefMenuItemSerializer
    permission_classes = [IsAuthenticated, RolePermission]
    required_roles = ["Chef", "Admin"]
    queryset = ChefDish.objects.select_related("chef", "dish").prefetch_related("versions", "dish__ingredients")

    def get_permissions(self):
        if getattr(self, "action", None) in ["list", "retrieve"]:
            return [AllowAny()]
        return super().get_permissions()

    def get_queryset(self):
        queryset = super().get_queryset()
        chef_identifier = self.request.query_params.get("chef")
        if chef_identifier:
            queryset = queryset.filter(chef__chef_id=chef_identifier)
        if getattr(self, "action", None) in ["list", "retrieve"]:
            if self.request.user.is_anonymous or self.request.user.user_type in ["Client", "Dispatch"]:
                return queryset.filter(active=True)
        if self.request.user.is_authenticated and self.request.user.user_type == "Chef":
            return queryset.filter(chef__user=self.request.user)
        return queryset

    def perform_create(self, serializer):
        profile, _ = ChefProfile.objects.get_or_create(user=self.request.user)
        serializer.save(chef=profile)

    def perform_update(self, serializer):
        instance = serializer.instance
        if self.request.user.user_type == "Chef" and instance.chef.user != self.request.user:
            raise PermissionDenied("Cannot modify another chef's menu item")
        serializer.save()
