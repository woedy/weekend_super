import 'package:flutter/material.dart';

import '../models/cook_profile.dart';
import '../models/dish.dart';
import '../models/order.dart';
import '../models/payout.dart';

class SampleData {
  const SampleData._();

  static CookProfile profile() {
    return initialProfile();
  }

  static List<Dish> dishes() {
    return <Dish>[
      Dish(
        id: 'dish-jollof',
        name: 'Smoky Party Jollof',
        description: 'Firewood-style jollof rice with grilled chicken and plantain sides.',
        price: 18.5,
        suggestedPrice: 19.0,
        leadTimeMinutes: 90,
        ingredients: const ['Rice', 'Tomato stew base', 'Chicken', 'Plantain'],
        inventory: 8,
        lowStockThreshold: 5,
        reorderRate: 0.72,
      ),
      Dish(
        id: 'dish-egusi',
        name: 'Egusi & Pounded Yam Feast',
        description: 'Rich egusi soup with goat meat, smoked fish and soft pounded yam.',
        price: 26.0,
        suggestedPrice: 27.5,
        leadTimeMinutes: 120,
        ingredients: const ['Egusi', 'Goat meat', 'Smoked fish', 'Spinach'],
        inventory: 3,
        lowStockThreshold: 4,
        reorderRate: 0.61,
      ),
      Dish(
        id: 'dish-smoothies',
        name: 'Athlete Recovery Smoothie Pack',
        description: 'Three bottled smoothies tailored for post-workout recovery.',
        price: 15.0,
        suggestedPrice: 15.0,
        leadTimeMinutes: 45,
        ingredients: const ['Banana', 'Kale', 'Ginger', 'Protein powder'],
        inventory: 14,
        lowStockThreshold: 6,
        reorderRate: 0.54,
      ),
    ];
  }

  static List<CookOrder> orders() {
    final now = DateTime.now();
    return <CookOrder>[
      CookOrder(
        id: 'order-1042',
        clientName: 'Chinyere Okonkwo',
        menuSummary: 'Egusi & Pounded Yam Feast x 4',
        scheduledAt: now.add(const Duration(hours: 6)),
        deliveryAddress: 'Campus North Residence 5B',
        instructions: 'Please package soup separately and label allergens.',
        dietaryNotes: const ['No crayfish', 'Allergic to peanuts'],
        stage: OrderStage.pending,
        groceryAdvance: 60,
        finalPayout: 120,
        platformFee: 18,
        conversation: const [
          OrderMessage(
            author: 'Chinyere',
            body: 'Hi Chef! Excited for Friday. Can you confirm goat meat is included?',
            timestamp: DateTime(2024, 8, 12, 9, 32),
            role: 'Client',
          ),
        ],
      ),
      CookOrder(
        id: 'order-1041',
        clientName: 'Team Falcons',
        menuSummary: 'Athlete Recovery Smoothie Pack x 10',
        scheduledAt: now.add(const Duration(hours: 2)),
        deliveryAddress: 'Athletics Center, Locker Room 3',
        instructions: 'Drop off at reception fridge and text coach when ready.',
        dietaryNotes: const ['No pineapple for batch 3'],
        stage: OrderStage.cooking,
        groceryAdvance: 45,
        finalPayout: 150,
        platformFee: 22,
        conversation: const [
          OrderMessage(
            author: 'Dispatch Bot',
            body: 'Courier assigned: Uche (ETA 2:45 PM).',
            timestamp: DateTime(2024, 8, 12, 8, 15),
            role: 'System',
          ),
          OrderMessage(
            author: 'Coach Amaka',
            body: 'Please keep batch 3 ginger-free — allergy noted.',
            timestamp: DateTime(2024, 8, 12, 8, 22),
            role: 'Client',
          ),
        ],
        receiptUploaded: true,
      ),
      CookOrder(
        id: 'order-1038',
        clientName: 'Ngozi Ude',
        menuSummary: 'Smoky Party Jollof x 2',
        scheduledAt: now.subtract(const Duration(hours: 20)),
        deliveryAddress: 'Midtown Co-working Hub',
        instructions: 'Deliver by 12:30 for investor lunch. Include disposable cutlery.',
        dietaryNotes: const ['Medium spice level'],
        stage: OrderStage.delivered,
        groceryAdvance: 30,
        finalPayout: 90,
        platformFee: 13,
        conversation: const [
          OrderMessage(
            author: 'Ngozi',
            body: 'Meal was a hit! Will leave a review tonight.',
            timestamp: DateTime(2024, 8, 11, 13, 10),
            role: 'Client',
          ),
        ],
      ),
    ];
  }

  static List<Payout> payouts() {
    final now = DateTime.now();
    return <Payout>[
      Payout(
        id: 'payout-203',
        orderId: 'order-1038',
        description: 'Final payout for Smoky Party Jollof',
        amount: 77,
        platformFee: 13,
        status: PayoutStatus.released,
        expectedOn: now.subtract(const Duration(days: 1)),
      ),
      Payout(
        id: 'payout-207',
        orderId: 'order-1041',
        description: 'Smoothie pack delivery final payout',
        amount: 128,
        platformFee: 22,
        status: PayoutStatus.pending,
        expectedOn: now.add(const Duration(days: 1)),
      ),
    ];
  }

  static List<String> serviceAreas() => combinedServiceAreas();

  static List<String> specialties() => specialtyTags;
}
