from __future__ import annotations

import logging
from dataclasses import dataclass
from decimal import Decimal

from django.conf import settings

from orders.models import EscrowLedgerEntry, Order

logger = logging.getLogger(__name__)


@dataclass
class PaymentSplit:
    grocery_advance: Decimal
    platform_fee: Decimal
    final_payout: Decimal


class PaymentGateway:
    """A lightweight gateway abstraction to simulate split payouts."""

    def create_hold(self, order: Order, amount: Decimal) -> str:
        reference = f"HOLD-{order.order_id}"
        logger.info("Holding %s for order %s", amount, order.order_id)
        return reference

    def release(self, reference: str, amount: Decimal) -> None:
        logger.info("Releasing %s for reference %s", amount, reference)


def calculate_split(order: Order) -> PaymentSplit:
    grocery_ratio = Decimal(getattr(settings, "GROCERY_ADVANCE_RATIO", Decimal("0.40")))
    platform_fee_ratio = Decimal(getattr(settings, "PLATFORM_FEE_RATIO", Decimal("0.12")))
    grocery_advance = (order.total_price * grocery_ratio).quantize(Decimal("0.01"))
    platform_fee = (order.total_price * platform_fee_ratio).quantize(Decimal("0.01"))
    final_payout = order.total_price - grocery_advance - platform_fee
    return PaymentSplit(grocery_advance, platform_fee, final_payout)


def record_split(order: Order, gateway: PaymentGateway | None = None) -> None:
    gateway = gateway or PaymentGateway()
    split = calculate_split(order)
    order.grocery_advance_amount = split.grocery_advance
    order.final_payout_amount = split.final_payout
    order.platform_fee_amount = split.platform_fee
    order.save(update_fields=["grocery_advance_amount", "final_payout_amount", "platform_fee_amount"])
    hold_reference = gateway.create_hold(order, order.total_price)
    EscrowLedgerEntry.objects.create(order=order, entry_type=EscrowLedgerEntry.EntryType.GROCERY_ADVANCE, amount=split.grocery_advance, reference=hold_reference)
    EscrowLedgerEntry.objects.create(order=order, entry_type=EscrowLedgerEntry.EntryType.PLATFORM_FEE, amount=split.platform_fee, reference=hold_reference)


def release_final_payout(order: Order, gateway: PaymentGateway | None = None) -> None:
    gateway = gateway or PaymentGateway()
    gateway.release(f"HOLD-{order.order_id}", order.final_payout_amount)
    EscrowLedgerEntry.objects.create(order=order, entry_type=EscrowLedgerEntry.EntryType.FINAL_PAYOUT, amount=order.final_payout_amount)
