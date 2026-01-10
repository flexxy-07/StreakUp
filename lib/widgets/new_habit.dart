import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewHabit extends StatefulWidget {
  final Function addHabit;
  NewHabit(this.addHabit);
  @override
  State<NewHabit> createState() => _NewHabitState();
}

class _NewHabitState extends State<NewHabit> {

  final _nameController = TextEditingController();
  final _daysController = TextEditingController();


  void _submit(){
    final name = _nameController.text;
    final days = int.tryParse(_daysController.text);

    if(name.isEmpty || days == null || days <= 0) return;

    widget.addHabit(name, days);

    Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'What Habit ?',
              labelStyle: TextStyle(
                fontSize: 14
              )
            ),
          ),
          TextField(
            controller: _daysController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'For how many days ?',
              labelStyle: TextStyle(
                fontSize: 14
              )
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: Text('Add Habit'),
          )
        ],
      ),
    );
  }
}