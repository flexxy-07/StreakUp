import 'dart:math';

import 'package:flutter/material.dart';
import 'package:streakup/models/habit.dart';
import 'package:streakup/widgets/habit_list.dart';
import 'package:streakup/widgets/new_habit.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
class _HomeScreenState extends State<HomeScreen> {
  final List<Habit> _habits = [];

  void addHabit(String name, int totalDays) {
    final habit = new Habit(
      name: name,
      id: DateTime.now().toString(),
      startDate: DateTime.now(),
      totalDays: totalDays,
      completedDays: 0,
    );

    setState(() {
      _habits.add(habit);
    });
  }

  void deleteHabit(String id){
   setState(() {
      _habits.removeWhere((h) => h.id == id);
   });
  }

  void markDayDone(String id){
    setState(() {
      final habit = _habits.firstWhere((h) => h.id == id);
      if(habit.completedDays < habit.totalDays){
        habit.completedDays++;
      }
    });
  }

  void resetStreak(String id){
    setState(() {
      final habit = _habits.firstWhere((h) => h.id == id);
      habit.completedDays = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StreakUp'),
      ),
      body: HabitList(_habits, markDayDone, deleteHabit, resetStreak),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          showModalBottomSheet(context: context, builder: (_){
            return NewHabit(addHabit);
          });
        },
      ),
    );
  }
}
