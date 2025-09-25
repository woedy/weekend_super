import 'package:flutter/material.dart';

const brandPrimary = Color(0xFFF94638);
const brandSurface = Color(0xFFF8F7FC);
const brandBackground = Color(0xFFF0EDF6);
const brandTextPrimary = Color(0xFF1F2933);
const brandTextSecondary = Color(0xFF52616B);
const brandBorder = Color(0xFFE0DCEC);
const brandSuccess = Color(0xFF0F9D58);
const brandWarning = Color(0xFFF4B400);
const brandDanger = Color(0xFFDB4437);

const double pagePadding = 20;

const List<String> defaultServiceAreas = <String>[
  'Campus North',
  'Campus South',
  'Downtown',
  'Midtown',
  'Tech Park',
  'Riverwalk',
];

const List<String> specialtyTags = <String>[
  'Meal prep',
  'Nigerian classics',
  'Vegan comfort',
  'Gluten friendly',
  'Budget friendly',
  'Family style',
  'Athlete fuel',
  'Low-carb',
];

String formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';
