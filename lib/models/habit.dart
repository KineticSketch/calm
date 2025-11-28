import 'package:flutter/material.dart';

enum HabitFrequency { daily, weekly }

class Habit {
  final String id;
  final String name;
  final String description;
  final HabitFrequency frequency;
  final Color color;
  final IconData icon;
  final List<DateTime> completedDates;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    this.frequency = HabitFrequency.daily,
    required this.color,
    required this.icon,
    this.completedDates = const [],
  });

  // Placeholder for copyWith, toMap, fromMap methods which will be needed later
}
