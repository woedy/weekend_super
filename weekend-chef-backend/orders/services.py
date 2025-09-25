from __future__ import annotations

import logging
from dataclasses import dataclass
from typing import Optional

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.core.exceptions import ImproperlyConfigured
from django.db import transaction

from accounts.models import User
from orders.models import EscrowLedgerEntry, Order, OrderStatusTransition
from payments.services import record_split, release_final_payout


@dataclass
class StatusChangeResult:
    order: Order
    transition: OrderStatusTransition


@transaction.atomic
def create_order_with_split(order: Order) -> Order:
    order.full_clean()
    order.save()
    record_split(order)
    return order


@transaction.atomic
def transition_order(order: Order, new_status: str, *, changed_by: Optional[User] = None, notes: str = "") -> StatusChangeResult:
    if new_status not in Order.Status.values:
        raise ValueError("Invalid order status")
    if order.status == new_status:
        transition = OrderStatusTransition.objects.filter(order=order, status=new_status).first()
        return StatusChangeResult(order, transition)
    order.status = new_status
    order.save(update_fields=["status", "status_updated_at"])
    client_actor = None
    if changed_by is not None:
        client_actor = getattr(changed_by, "client", None)
        if isinstance(changed_by, OrderStatusTransition._meta.get_field("changed_by").related_model):
            client_actor = changed_by
    transition = OrderStatusTransition.objects.create(order=order, status=new_status, changed_by=client_actor, notes=notes)
    if new_status == Order.Status.ACCEPTED:
        record_split(order)
    if new_status == Order.Status.DELIVERED:
        release_final_payout(order)
    try:
        channel_layer = get_channel_layer()
    except ImproperlyConfigured:
        channel_layer = None
    if channel_layer:
        try:
            async_to_sync(channel_layer.group_send)(
                f"order_{order.pk}",
                {
                    "type": "order.status",
                    "status": new_status,
                    "order_id": order.order_id,
                },
            )
        except Exception:  # pragma: no cover - log and continue when redis unavailable
            logging.getLogger(__name__).debug("Skipping status broadcast; channel layer unavailable.", exc_info=True)
    return StatusChangeResult(order, transition)


def apply_payout_adjustment(order: Order, amount):
    EscrowLedgerEntry.objects.create(order=order, entry_type=EscrowLedgerEntry.EntryType.REFUND, amount=amount)
    order.final_payout_amount += amount
    order.save(update_fields=["final_payout_amount"])
