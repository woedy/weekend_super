import os
import random
import uuid

from django.contrib.auth import get_user_model
from django.db import models
from django.db.models.signals import post_save, pre_save
from django.utils import timezone

from decimal import Decimal

from django.core.exceptions import ValidationError

from food.models import Dish
from weekend_chef_project.utils import unique_chef_id_generator


User = get_user_model()


CHEF_TYPES = [
    ('Home Chef', 'Home Chef'),
    ('Professional Chef', 'Professional Chef'),
    ('Culinary Student', 'Culinary Student'),
    ('Hobby Cook', 'Hobby Cook'),
    ('Catering Professional', 'Catering Professional')
]

CHEF_CUISINE_SPECIALTIES = [
    ('Local', 'Local Cuisine'),
    ('International', 'International Cuisine'),
    ('Fusion', 'Fusion Cuisine'),
    ('Healthy', 'Healthy Cooking'),
    ('Baking', 'Baking & Desserts'),
    ('Vegetarian', 'Vegetarian Specialist'),
    ('Vegan', 'Vegan Cuisine')
]


class CuisineSpecialty(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)
    icon = models.ImageField(upload_to='cuisine_icons/', null=True, blank=True)

    active = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class Certification(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)
    icon = models.ImageField(upload_to='chef_certifications/', null=True, blank=True)

    active = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name



CHEF_AVAILABILITY = [
    ('Saturday', 'Saturday'),
    ('Sunday', 'Sunday'),
    ('Both', 'Both'),
    
]


class ChefProfile(models.Model):
    class ReviewStatus(models.TextChoices):
        PENDING = "pending", "Pending"
        APPROVED = "approved", "Approved"
        REJECTED = "rejected", "Rejected"

    user = models.OneToOneField(User, on_delete=models.CASCADE)
    chef_id = models.CharField(max_length=200, null=True, blank=True)

    chef_type = models.CharField(max_length=100, choices=CHEF_TYPES, null=True, blank=True)
    certifications = models.ManyToManyField('Certification', blank=True)
    
    # Location & Availability
    kitchen_address = models.TextField(null=True, blank=True)

    kitchen_location = models.CharField(max_length=5000, null=True, blank=True)
    lat = models.DecimalField(default=0.0, max_digits=50, decimal_places=20, null=True, blank=True)
    lng = models.DecimalField(default=0.0, max_digits=50, decimal_places=20, null=True, blank=True)

    service_radius = models.IntegerField(default=10)  # km
    availability = models.CharField(max_length=100, choices=CHEF_AVAILABILITY, null=True, blank=True)
    
    # Professional Details
    cuisine_specialties = models.ManyToManyField('CuisineSpecialty', blank=True)
    years_of_experience = models.IntegerField(null=True, blank=True)
    
    max_order_capacity = models.IntegerField(default=10)

    # Performance Metrics
    total_orders = models.IntegerField(default=0)
    average_rating = models.FloatField(default=0)

    active = models.BooleanField(default=False)
    review_status = models.CharField(max_length=20, choices=ReviewStatus.choices, default=ReviewStatus.PENDING)
    review_notes = models.TextField(blank=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        if self.review_status != self.ReviewStatus.PENDING and self.reviewed_at is None:
            self.reviewed_at = timezone.now()
        super().save(*args, **kwargs)



def pre_save_chef_id_receiver(sender, instance, *args, **kwargs):
    if not instance.chef_id:
        instance.chef_id = unique_chef_id_generator(instance)

pre_save.connect(pre_save_chef_id_receiver, sender=ChefProfile)




class ChefDish(models.Model):

    chef = models.ForeignKey(ChefProfile, on_delete=models.CASCADE, related_name="chef_dishes")
    dish = models.ForeignKey(Dish, on_delete=models.CASCADE, related_name="dish_chefs")

    small_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    small_value = models.CharField(max_length=2000, null=True, blank=True)

    medium_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    medium_value = models.CharField(max_length=2000, null=True, blank=True)

    large_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    large_value = models.CharField(max_length=2000, null=True, blank=True)


    is_archived = models.BooleanField(default=False)

    active = models.BooleanField(default=False)
    grocery_budget_estimate = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    menu_version = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


    def clean(self):
        price_fields = [self.small_price, self.medium_price, self.large_price]
        for price in price_fields:
            if price is not None and price < 0:
                raise ValidationError("Price values must be positive.")

    def compute_grocery_estimate(self) -> Decimal:
        ingredients = self.dish.ingredients.all()
        return sum((ingredient.price for ingredient in ingredients), Decimal("0"))

    def snapshot(self):
        return {
            "small_price": str(self.small_price or "0"),
            "medium_price": str(self.medium_price or "0"),
            "large_price": str(self.large_price or "0"),
            "grocery_budget_estimate": str(self.grocery_budget_estimate),
            "active": self.active,
        }

    def save(self, *args, **kwargs):
        creating = self.pk is None
        create_snapshot = creating
        if not creating:
            previous = ChefDish.objects.get(pk=self.pk)
            if any([
                previous.small_price != self.small_price,
                previous.medium_price != self.medium_price,
                previous.large_price != self.large_price,
                previous.active != self.active,
            ]):
                self.menu_version = previous.menu_version + 1
                create_snapshot = True
        self.grocery_budget_estimate = self.compute_grocery_estimate()
        self.full_clean()
        super().save(*args, **kwargs)
        if create_snapshot:
            MenuItemVersion.objects.create(menu_item=self, version=self.menu_version, snapshot=self.snapshot())


class MenuItemVersion(models.Model):
    menu_item = models.ForeignKey(ChefDish, related_name="versions", on_delete=models.CASCADE)
    version = models.PositiveIntegerField()
    snapshot = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("menu_item", "version")
        ordering = ["-created_at"]





class ChefReview(models.Model):
    review_id = models.CharField(max_length=200, null=True, blank=True)

    chef = models.ForeignKey(ChefProfile, on_delete=models.CASCADE, related_name="complaints_complaints")

    review = models.TextField(null=True, blank=True)


    is_archived = models.BooleanField(default=False)

    active = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)




def pre_save_review_id_receiver(sender, instance, *args, **kwargs):
    if not instance.review_id:
        instance.review_id = unique_review_id_generator(instance)

pre_save.connect(pre_save_review_id_receiver, sender=ChefReview)







class ChefGallery(models.Model):
    name = models.CharField(max_length=200)
    chef = models.ForeignKey(ChefProfile, on_delete=models.CASCADE)
    description = models.TextField()
    photo = models.ImageField(upload_to='chef/gallery/', null=True, blank=True)


def chef_document_upload(instance, filename):
    ext = filename.split('.')[-1]
    return f"chef/documents/{instance.profile.chef_id or instance.profile.id}/{uuid.uuid4()}.{ext}"


class ChefDocument(models.Model):
    class DocumentType(models.TextChoices):
        IDENTITY = "identity", "Identity"
        CERTIFICATION = "certification", "Certification"
        KITCHEN = "kitchen", "Kitchen"

    profile = models.ForeignKey(ChefProfile, on_delete=models.CASCADE, related_name="documents")
    document_type = models.CharField(max_length=32, choices=DocumentType.choices)
    file = models.FileField(upload_to=chef_document_upload)
    description = models.TextField(blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-uploaded_at"]

    def __str__(self):
        return f"{self.profile.user.email} - {self.document_type}"



