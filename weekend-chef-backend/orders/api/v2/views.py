from django.db.models import Q
from django.db.models import Q
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from accounts.api.permissions import RolePermission
from orders.api.v2.serializers import (
    DeliveryProofSerializer,
    OrderAllergenAcknowledgementSerializer,
    OrderAllergenReportSerializer,
    OrderAllergenSubmissionSerializer,
    OrderRatingSerializer,
    OrderSerializer,
    OrderStatusSerializer,
)
from orders.models import DeliveryProof, Order, OrderAllergenReport


class OrderViewSet(viewsets.ModelViewSet):
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated, RolePermission]
    required_roles = ["Client", "Chef", "Dispatch", "Admin"]
    queryset = Order.objects.select_related("client__user", "chef__user").prefetch_related(
        "escrow_entries", "status_transitions", "allergen_report__allergies"
    )

    def get_permissions(self):
        if getattr(self, "action", None) in ["list", "retrieve"]:
            return [IsAuthenticated()]
        return super().get_permissions()

    def get_queryset(self):
        user = self.request.user
        qs = super().get_queryset()
        if user.user_type == "Client":
            return qs.filter(client__user=user)
        if user.user_type == "Chef":
            return qs.filter(chef__user=user)
        if user.user_type == "Dispatch":
            return qs.filter(Q(dispatch__user=user) | Q(dispatch__isnull=True))
        return qs

    def perform_create(self, serializer):
        client_relation = getattr(self.request.user, "clients", None)
        if client_relation is None:
            raise ValidationError({"detail": "Only clients can place orders."})
        client = client_relation.first()
        if client is None:
            raise ValidationError({"detail": "Client profile is required."})
        serializer.save(client=client)

    @action(detail=True, methods=["post"], url_path="status", url_name="status")
    def change_status(self, request, pk=None):
        order = self.get_object()
        serializer = OrderStatusSerializer(data=request.data, context={"order": order, "user": request.user})
        serializer.is_valid(raise_exception=True)
        order = serializer.save()
        return Response(OrderSerializer(order, context=self.get_serializer_context()).data)

    @action(detail=True, methods=["post"], url_path="delivery-proof", url_name="delivery-proof")
    def delivery_proof(self, request, pk=None):
        order = self.get_object()
        if request.user.user_type != "Dispatch":
            return Response({"detail": "Only dispatchers can submit proof."}, status=status.HTTP_403_FORBIDDEN)
        dispatcher = getattr(request.user, "dispatchdriver", None)
        if dispatcher is None:
            raise ValidationError({"detail": "Dispatcher profile required."})
        serializer = DeliveryProofSerializer(data=request.data, context={"order": order, "dispatcher": dispatcher})
        serializer.is_valid(raise_exception=True)
        proof = serializer.save()
        return Response(DeliveryProofSerializer(proof).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"], url_path="rating", url_name="rating")
    def rate_order(self, request, pk=None):
        order = self.get_object()
        client_relation = getattr(request.user, "clients", None)
        if client_relation is None or client_relation.first() != order.client:
            return Response({"detail": "Only the client who placed the order can rate it."}, status=status.HTTP_403_FORBIDDEN)
        serializer = OrderRatingSerializer(data=request.data, context={"order": order})
        serializer.is_valid(raise_exception=True)
        rating = serializer.save()
        return Response(OrderRatingSerializer(rating).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"], url_path="report-allergens", url_name="report-allergens")
    def report_allergens(self, request, pk=None):
        order = self.get_object()
        client_relation = getattr(request.user, "clients", None)
        if client_relation is None or client_relation.first() != order.client:
            return Response({"detail": "Only the client who placed the order can submit allergens."}, status=status.HTTP_403_FORBIDDEN)
        report, _ = OrderAllergenReport.objects.get_or_create(order=order)
        serializer = OrderAllergenSubmissionSerializer(instance=report, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(OrderAllergenReportSerializer(report).data, status=status.HTTP_200_OK)

    @action(detail=True, methods=["post"], url_path="acknowledge-allergens", url_name="acknowledge-allergens")
    def acknowledge_allergens(self, request, pk=None):
        order = self.get_object()
        if request.user.user_type != "Chef" or getattr(request.user, "chefprofile", None) != order.chef:
            return Response({"detail": "Only the assigned chef can acknowledge allergens."}, status=status.HTTP_403_FORBIDDEN)
        try:
            report = order.allergen_report
        except OrderAllergenReport.DoesNotExist:
            return Response({"detail": "No allergen report has been submitted for this order."}, status=status.HTTP_400_BAD_REQUEST)
        if not report.reported_by_client:
            return Response({"detail": "Allergen report must be submitted by the client before acknowledgement."}, status=status.HTTP_400_BAD_REQUEST)
        serializer = OrderAllergenAcknowledgementSerializer(instance=report, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(OrderAllergenReportSerializer(report).data, status=status.HTTP_200_OK)
