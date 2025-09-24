from django.utils import timezone
from django.db import models

from chats.models import PrivateChatRoom
from chef.models import ChefProfile
from clients.models import Client, ClientHomeLocation
from dispatch.models import DispatchDriver
from django.db.models.signals import pre_save

from food.models import CustomizationOption, Dish, DishIngredient
from weekend_chef_project.utils import unique_order_id_generator


# Cart model
class Cart(models.Model):
    client = models.OneToOneField(Client, related_name='cart', on_delete=models.CASCADE)
    purchased = models.BooleanField(default=False)  # Add purchased field
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Cart for {self.client.user.first_name}"









class CustomizationValue(models.Model):
    customization_option = models.ForeignKey(CustomizationOption, related_name='values', on_delete=models.CASCADE)
    #value = models.CharField(max_length=100)  # e.g., "Chicken", "Fish", "Hot", "Mild"
    quantity = models.PositiveIntegerField()

    def __str__(self):
        return f"{self.customization_option.name}: {self.quantity}"




# CartItem model to hold individual items in the cart
class CartItem(models.Model):
    cart = models.ForeignKey(Cart, related_name='items', on_delete=models.CASCADE)
    dish = models.ForeignKey(Dish, related_name='cart_items', on_delete=models.CASCADE)
    is_custom = models.BooleanField(default=False)

    quantity = models.PositiveIntegerField()
    value = models.CharField(max_length=200)
    package = models.CharField(max_length=200)
    package_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    item_total_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    customizations = models.ManyToManyField(CustomizationValue, related_name='cart_items', blank=True)
    special_notes = models.TextField(max_length=100, null=True, blank=True)

    is_archived = models.BooleanField(default=False)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


    def __str__(self):
        return f"{self.dish.name} (x{self.quantity})"

    def total_price(self):
        # Start with the base price of the product
        package_price = float(self.package_price)
        
        # Add the price of each customization option (meat type, spice level, etc.)
        for customization in self.customizations.all():
            package_price += float(customization.customization_option.price) * customization.quantity

        # Multiply by quantity (if more than 1 item)
        return float(package_price) * self.quantity





ORDER_STATUS = [
        ('Review', 'Review'),
        ('Pending', 'Pending'),
        ('Initiated', 'Initiated'),
        ('Cooking', 'Cooking'),
        ('Completed', 'Completed'),

    ]
class Order(models.Model):
    order_id = models.CharField(max_length=255, blank=True, null=True, unique=True)
    Cart = models.ForeignKey(Cart, related_name='oeder_cart', on_delete=models.CASCADE, null=True, blank=True)

    client = models.ForeignKey(Client, related_name='client_orders', on_delete=models.CASCADE)
    dispatch = models.ForeignKey(DispatchDriver, related_name='dispatch_orders', on_delete=models.CASCADE, null=True, blank=True)

    total_price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    paid = models.BooleanField(default=False)

    room = models.ForeignKey(PrivateChatRoom, on_delete=models.SET_NULL, null=True, related_name='booking_chat_rooms')

    order_date = models.DateField(auto_now=False, auto_now_add=False, null=True, blank=True)
    order_time = models.TimeField(auto_now=False, auto_now_add=False, null=True, blank=True)


    delivery_date = models.DateField(auto_now=False, auto_now_add=False, null=True, blank=True)
    delivery_time = models.TimeField(auto_now=False, auto_now_add=False, null=True, blank=True)
    delivery_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    tax = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    location = models.ForeignKey(ClientHomeLocation, related_name='client_ordder_locations', on_delete=models.CASCADE, null=True, blank=True)
    distance = models.DecimalField(max_digits=10, decimal_places=3, default=0)

    fast_order = models.BooleanField(default=False)




    status = models.CharField(choices=ORDER_STATUS, default='Review', max_length=200)


    def __str__(self):
        return f"Order #{self.id} for {self.client.user.first_name}"




def pre_save_order_id_receiver(sender, instance, *args, **kwargs):
    if not instance.order_id:
        instance.order_id = unique_order_id_generator(instance)

pre_save.connect(pre_save_order_id_receiver, sender=Order)




status_choices = [
        ('Pending', 'Pending'),
        ('Shipped', 'Shipped'),
        ('Delivered', 'Delivered'),
        ('Cancelled', 'Cancelled'),
    ]


class OrderStatus(models.Model):
    order = models.ForeignKey(Order, related_name='order_statuses', on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=status_choices, default='Pending')
    created_at = models.DateTimeField(auto_now_add=True)



class OrderItem(models.Model):
    order = models.ForeignKey(Order, related_name='items', on_delete=models.CASCADE)
    cart_item = models.ForeignKey(CartItem, related_name='order_items', on_delete=models.CASCADE)  # Link to CartItem
    quantity = models.PositiveIntegerField()  # Quantity of the item in the order

    def __str__(self):
        return f"{self.cart_item.dish.name} (x{self.quantity})"

    def total_price(self):
        """
        Calculate the total price for this OrderItem based on the CartItem's dish price and customizations.
        """
        base_price = self.cart_item.dish.base_price
        # Add customizations price from the associated CartItem
        for customization in self.cart_item.customizations.all():
            base_price += customization.customization_option.price * customization.quantity
        # Return the total price considering the quantity
        return base_price * self.quantity





class OrderPayment(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='order_payments')
    payment_method = models.CharField(max_length=200,  null=True, blank=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)


    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


class OrderRating(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='order_ratings')
    rating = models.IntegerField(default=0)
    report = models.TextField(null=True, blank=True)

    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)




class ShoppingList(models.Model):
    order_item = models.ForeignKey(OrderItem, related_name='shopping_lists', on_delete=models.CASCADE)
    ingredient = models.ForeignKey(DishIngredient, related_name='shopping_lists', on_delete=models.CASCADE)
    quantity = models.DecimalField(max_digits=6, decimal_places=2)  # Quantity needed for the order item
    unit = models.CharField(max_length=50)  # Unit of the ingredient (kg, grams, liters, etc.)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.quantity} {self.unit} of {self.ingredient.name} for {self.order_item.dish.name}"




