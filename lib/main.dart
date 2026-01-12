import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('habits');

    if(data == null) return;

    final List decoded = json.decode(data);

    setState(() {
      _habits.clear();
      _habits.addAll(
        decoded.map((e) => Habit.fromMap(e)).toList(),
      );
    });
  }
  
  @override
  void initState(){
    super.initState();
    _loadHabits();
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();

    final data = json.encode(
    _habits.map((h) => h.toMap()).toList(),
    );

    await prefs.setString('habits', data);
  } 

  bool _isSameDay(DateTime a, DateTime b){
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void addHabit(String name, int totalDays) {
    final habit = new Habit(
      name: name,
      id: DateTime.now().toString(),
      startDate: DateTime.now(),
      totalDays: totalDays,
      completedDays: 0,
      lastCompletedDate: null,
      completedDates:[]
    );

    setState(() {
      _habits.add(habit);
    });

    _saveHabits();
  }

  void deleteHabit(String id){
   setState(() {
      _habits.removeWhere((h) => h.id == id);
   });
   _saveHabits();
  }

  void markDayDone(String id){
    setState(() {
      final habit = _habits.firstWhere((h) => h.id == id);
      final today = DateTime.now();

      bool alreadyDoneToday = habit.completedDates.any((d) => d.year == today.year && d.month == today.month && d.day == today.day);

      if(!alreadyDoneToday && habit.completedDates.length < habit.totalDays){
        habit.completedDates.add(today);
        habit.lastCompletedDate = today;
      }
    });
    _saveHabits();
  }

  void resetStreak(String id){
    setState(() {
      final habit = _habits.firstWhere((h) => h.id == id);
      habit.completedDates.clear();
      habit.lastCompletedDate = null;
    });

    _saveHabits();
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
