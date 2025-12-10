import 'package:flutter/material.dart';

class RoutineItem {
  final String id;
  final String title;
  final TimeOfDay time;
  bool isCompleted;

  RoutineItem({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
  });
}
