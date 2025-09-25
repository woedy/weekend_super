from django.contrib import admin

from orders.models import (
    Cart,
    CartItem,
    CustomizationValue,
    DeliveryProof,
    EscrowLedgerEntry,
    Order,
    OrderItem,
    OrderPayment,
    OrderRating,
    OrderStatusTransition,
    ShoppingList,
)

admin.site.register(Cart)
admin.site.register(CustomizationValue)
admin.site.register(CartItem)

admin.site.register(Order)
admin.site.register(OrderStatusTransition)
admin.site.register(OrderItem)
admin.site.register(OrderPayment)
admin.site.register(OrderRating)
admin.site.register(ShoppingList)
admin.site.register(EscrowLedgerEntry)
admin.site.register(DeliveryProof)
