import os
import random

from django.contrib.auth import get_user_model
from django.db import models
from django.db.models.signals import post_save, pre_save

from orders.models import Order


User = get_user_model()


STATUS_CHOICE = (

    ('Created', 'Created'),
    ('Pending', 'Pending'),

    ('Approved', 'Approved'),
    ('Declined', 'Declined'),

    ('Unresolved', 'Unresolved'),
    ('Resolved', 'Resolved'),

    ('Review', 'Review'),

    ('Completed', 'Completed'),
    ('Canceled', 'Canceled'),
)



class ClientComplaint(models.Model):
    complaint_id = models.CharField(max_length=200, null=True, blank=True)

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="complaints_complaints")

    title = models.CharField(max_length=1000, null=True, blank=True)
    note = models.TextField(null=True, blank=True)

    status = models.CharField(max_length=255, default="Pending", null=True, blank=True, choices=STATUS_CHOICE)

    is_archived = models.BooleanField(default=False)

    active = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)




import uuid

def unique_complaint_id_generator(instance):
    return str(uuid.uuid4())

def pre_save_complaint_id_receiver(sender, instance, *args, **kwargs):
    if not instance.complaint_id:
        instance.complaint_id = unique_complaint_id_generator(instance)

pre_save.connect(pre_save_complaint_id_receiver, sender=ClientComplaint)



class DisputeTicket(models.Model):
    STATUS_CHOICES = [
        ('open', 'Open'),
        ('in_review', 'In Review'),
        ('resolved', 'Resolved'),
    ]

    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='dispute_tickets')
    raised_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='raised_disputes')
    description = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='open')
    resolution_notes = models.TextField(blank=True)
    payout_adjustment = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Dispute {self.pk} for {self.order.order_id}"
