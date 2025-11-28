import 'package:flutter/material.dart';

class AddEditHabitScreen extends StatelessWidget {
  const AddEditHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),
      body: const Center(child: Text('Form to add/edit habit')),
    );
  }
}
