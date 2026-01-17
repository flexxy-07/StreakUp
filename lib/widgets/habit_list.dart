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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF5B4EF5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.add_circle_outline,
                size: 48,
                color: Color(0xFF5B4EF5),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "No Habits Yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Start building your streak by creating your first habit",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: habits.length,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemBuilder: (context, index) {
        final habit = habits[index];
        final progress = habit.completedDates.length / habit.totalDays;
        final isCompleted = habit.completedDates.length >= habit.totalDays;
        final alreadyDoneToday = habit.completedDates.any((d) =>
            d.year == DateTime.now().year &&
            d.month == DateTime.now().month &&
            d.day == DateTime.now().day);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HabitCard(habit, markDayDone, resetStreak, deleteHabit),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted ? Color(0xFF10B981).withOpacity(0.2) : Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${habit.completedDates.length} / ${habit.totalDays} days",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Color(0xFF10B981).withOpacity(0.1)
                                  : alreadyDoneToday
                                      ? Color(0xFFF59E0B).withOpacity(0.1)
                                      : Color(0xFF5B4EF5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCompleted
                                  ? '✓ Done'
                                  : alreadyDoneToday
                                      ? 'Done Today'
                                      : '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isCompleted
                                    ? Color(0xFF10B981)
                                    : alreadyDoneToday
                                        ? Color(0xFFF59E0B)
                                        : Color(0xFF5B4EF5),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? Color(0xFF10B981) : Color(0xFF5B4EF5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
