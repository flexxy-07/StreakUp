import 'package:flutter/material.dart';

class NewHabit extends StatefulWidget {
  final Function addHabit;
  NewHabit(this.addHabit);
  @override
  State<NewHabit> createState() => _NewHabitState();
}

class _NewHabitState extends State<NewHabit> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text('New habit Form'),
    );
  }
}