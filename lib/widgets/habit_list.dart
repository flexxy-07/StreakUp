import 'package:flutter/material.dart';
import 'package:streakup/models/habit.dart';
import 'package:streakup/widgets/habit_card.dart';

class HabitList extends StatelessWidget {
  final List<Habit> habits;
  final Function markDayDone;
  final Function deleteHabit;
  final Function resetStreak;

  HabitList(this.habits, this.markDayDone, this.deleteHabit, this.resetStreak);

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return Center(
        child: Text("No Habits yet, getUp you lazyBoi."),
      );
    }

    return ListView.builder(
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];

        final progress = habit.completedDates.length / habit.totalDays;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HabitCard(habit, markDayDone, resetStreak, deleteHabit),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => markDayDone(habit.id),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => deleteHabit(habit.id),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Progress text
                  Text(
                    "${habit.completedDates.length} / ${habit.totalDays} days completed",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),

                  SizedBox(height: 8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
