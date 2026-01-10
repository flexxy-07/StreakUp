import 'package:flutter/material.dart';
import 'package:streakup/models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  HabitCard(this.habit);

  @override
  Widget build(BuildContext context) {
    final progress = habit.completedDays / habit.totalDays;
    return Scaffold(
      appBar: AppBar(title: Text(habit.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(habit.name),
            SizedBox(height: 20),

            Text('Progress : ${(progress * 100).toStringAsFixed(0)}%'),

            SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 20,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),

            ElevatedButton(onPressed: () {}, child: Text('Button')),
          ],
        ),
      ),
    );
  }
}
