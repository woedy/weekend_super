from decimal import Decimal

from django.core.exceptions import ValidationError
from django.db import models
from django.db.models.signals import post_save, pre_save
from django.utils import timezone

from chats.models import PrivateChatRoom
from chef.models import ChefProfile
from clients.models import Client, ClientHomeLocation
from dispatch.models import DispatchDriver
from food.models import CustomizationOption, Dish, DishIngredient
from weekend_chef_project.utils import unique_order_id_generator


class Cart(models.Model):
    client = models.ForeignKey(Client, related_name="carts", on_delete=models.CASCADE)
    purchased = models.BooleanField(default=False)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Cart for {self.client.user.first_name}"


class CustomizationValue(models.Model):
    customization_option = models.ForeignKey(CustomizationOption, related_name="values", on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField()

    def __str__(self):
        return f"{self.customization_option.name}: {self.quantity}"


class CartItem(models.Model):
    cart = models.ForeignKey(Cart, related_name="items", on_delete=models.CASCADE)
    dish = models.ForeignKey(Dish, related_name="cart_items", on_delete=models.CASCADE)
    is_custom = models.BooleanField(default=False)
    quantity = models.PositiveIntegerField()
    value = models.CharField(max_length=200)
    package = models.CharField(max_length=200)
    package_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    item_total_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    customizations = models.ManyToManyField(CustomizationValue, related_name="cart_items", blank=True)
    special_notes = models.TextField(max_length=100, null=True, blank=True)
    is_archived = models.BooleanField(default=False)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.dish.name} (x{self.quantity})"

    def total_price(self):
        base_price = Decimal(self.package_price or 0)
        for customization in self.customizations.all():
            base_price += Decimal(customization.customization_option.price) * customization.quantity
        return base_price * self.quantity


class Order(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        ACCEPTED = "accepted", "Accepted"
        COOKING = "cooking", "Cooking"
        READY = "ready", "Ready for pickup"
        DISPATCHED = "dispatched", "Dispatched"
        DELIVERED = "delivered", "Delivered"
        COMPLETED = "completed", "Completed"
        CANCELLED = "cancelled", "Cancelled"

    order_id = models.CharField(max_length=255, blank=True, null=True, unique=True)
    cart = models.ForeignKey(Cart, related_name="order_cart", on_delete=models.CASCADE, null=True, blank=True)
    client = models.ForeignKey(Client, related_name="client_orders", on_delete=models.CASCADE)
    chef = models.ForeignKey(ChefProfile, related_name="chef_orders", on_delete=models.CASCADE)
    dispatch = models.ForeignKey(DispatchDriver, related_name="dispatch_orders", on_delete=models.CASCADE, null=True, blank=True)
    total_price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    grocery_advance_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    final_payout_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    platform_fee_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    paid = models.BooleanField(default=False)
    room = models.ForeignKey(PrivateChatRoom, on_delete=models.SET_NULL, null=True, blank=True, related_name="booking_chat_rooms")
    delivery_window_start = models.DateTimeField(null=True, blank=True)
    delivery_window_end = models.DateTimeField(null=True, blank=True)
    delivery_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    tax = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    location = models.ForeignKey(ClientHomeLocation, related_name="client_order_locations", on_delete=models.CASCADE, null=True, blank=True)
    distance = models.DecimalField(max_digits=10, decimal_places=3, default=0)
    fast_order = models.BooleanField(default=False)
    status = models.CharField(choices=Status.choices, default=Status.PENDING, max_length=50)
    status_updated_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Order #{self.id} for {self.client.user.first_name}"

    def clean(self):
        if self.delivery_window_start and self.delivery_window_end and self.delivery_window_start >= self.delivery_window_end:
            raise ValidationError("Delivery window end must be after start.")
        if self.delivery_window_start and self.chef_id:
            overlap = Order.objects.filter(
                chef=self.chef,
                delivery_window_end__gt=self.delivery_window_start,
                delivery_window_start__lt=self.delivery_window_end,
            ).exclude(pk=self.pk)
            if overlap.exists():
                raise ValidationError("Chef already has an order in this window.")

    def schedule_conflicts(self):
        return Order.objects.filter(
            chef=self.chef,
            delivery_window_end__gt=self.delivery_window_start,
            delivery_window_start__lt=self.delivery_window_end,
        ).exclude(pk=self.pk)


def pre_save_order_id_receiver(sender, instance, *args, **kwargs):
    if not instance.order_id:
        instance.order_id = unique_order_id_generator(instance)


pre_save.connect(pre_save_order_id_receiver, sender=Order)


class OrderStatusTransition(models.Model):
    order = models.ForeignKey(Order, related_name="status_transitions", on_delete=models.CASCADE)
    status = models.CharField(max_length=50, choices=Order.Status.choices)
    changed_by = models.ForeignKey(Client, null=True, blank=True, on_delete=models.SET_NULL)
    notes = models.TextField(blank=True)
    changed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-changed_at"]


class OrderStatus(OrderStatusTransition):
    class Meta:
        proxy = True
        verbose_name = "Order Status"
        verbose_name_plural = "Order Statuses"


class OrderItem(models.Model):
    order = models.ForeignKey(Order, related_name="items", on_delete=models.CASCADE)
    cart_item = models.ForeignKey(CartItem, related_name="order_items", on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField()

    def __str__(self):
        return f"{self.cart_item.dish.name} (x{self.quantity})"

    def total_price(self):
        base_price = Decimal(self.cart_item.package_price or 0)
        for customization in self.cart_item.customizations.all():
            base_price += Decimal(customization.customization_option.price) * customization.quantity
        return base_price * self.quantity


class OrderPayment(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name="order_payments")
    payment_method = models.CharField(max_length=200, null=True, blank=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


class EscrowLedgerEntry(models.Model):
    class EntryType(models.TextChoices):
        GROCERY_ADVANCE = "grocery_advance", "Grocery advance"
        PLATFORM_FEE = "platform_fee", "Platform fee"
        FINAL_PAYOUT = "final_payout", "Final payout"
        REFUND = "refund", "Refund"

    order = models.ForeignKey(Order, related_name="escrow_entries", on_delete=models.CASCADE)
    entry_type = models.CharField(max_length=32, choices=EntryType.choices)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    reference = models.CharField(max_length=255, blank=True)
    processed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["processed_at"]


class OrderRating(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name="order_ratings")
    rating = models.IntegerField(default=0)
    report = models.TextField(null=True, blank=True)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


class ShoppingList(models.Model):
    order_item = models.ForeignKey(OrderItem, related_name="shopping_lists", on_delete=models.CASCADE)
    ingredient = models.ForeignKey(DishIngredient, related_name="shopping_lists", on_delete=models.CASCADE)
    quantity = models.DecimalField(max_digits=6, decimal_places=2)
    unit = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.quantity} {self.unit} of {self.ingredient.name} for {self.order_item.cart_item.dish.name}"


class DeliveryProof(models.Model):
    order = models.OneToOneField(Order, related_name="delivery_proof", on_delete=models.CASCADE)
    photo = models.ImageField(upload_to="orders/delivery_proofs/", null=True, blank=True)
    signature = models.TextField(blank=True)
    submitted_by = models.ForeignKey(DispatchDriver, on_delete=models.CASCADE, related_name="delivery_proofs")
    submitted_at = models.DateTimeField(auto_now_add=True)


post_save.connect(
    lambda sender, instance, created, **kwargs: OrderStatusTransition.objects.create(order=instance, status=instance.status)
    if created else None,
    sender=Order,
)
