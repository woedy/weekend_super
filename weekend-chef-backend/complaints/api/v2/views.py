from rest_framework import mixins, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from accounts.api.permissions import RolePermission
from complaints.api.v2.serializers import DisputeResolutionSerializer, DisputeTicketSerializer
from complaints.models import DisputeTicket


class DisputeTicketViewSet(mixins.CreateModelMixin, mixins.ListModelMixin, mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    serializer_class = DisputeTicketSerializer
    permission_classes = [IsAuthenticated, RolePermission]
    required_roles = ["Client", "Admin"]

    def get_queryset(self):
        user = self.request.user
        qs = DisputeTicket.objects.select_related("order", "raised_by")
        if user.user_type == "Client":
            return qs.filter(raised_by=user)
        return qs

    def get_serializer_context(self):
        ctx = super().get_serializer_context()
        ctx["user"] = self.request.user
        return ctx

    def get_permissions(self):
        if self.action == "resolve":
            self.required_roles = ["Admin"]
        else:
            self.required_roles = ["Client", "Admin"]
        return super().get_permissions()

    @action(detail=True, methods=["patch"], url_path="resolve")
    def resolve(self, request, pk=None):
        if request.user.user_type != "Admin":
            return Response({"detail": "Only admins can resolve disputes."}, status=403)
        dispute = self.get_object()
        serializer = DisputeResolutionSerializer(dispute, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        dispute = serializer.save()
        return Response(DisputeTicketSerializer(dispute).data)
