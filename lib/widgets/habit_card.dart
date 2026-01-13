import 'package:flutter/material.dart';
import 'package:streakup/models/habit.dart';
import 'dart:math' as math;

class HabitCard extends StatefulWidget {
  final Habit habit;
  final Function markDayDone;
  final Function resetStreak;
  final Function deleteHabit;
  HabitCard(this.habit, this.markDayDone, this.resetStreak, this.deleteHabit);

  @override
  _HabitCardState createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _triggerCelebration() {
    _celebrationController.forward().then((_) {
      _celebrationController.reverse();
    });
  }

  List<DateTime> get last14Days {
    return List.generate(14, (index) {
      return DateTime.now().subtract(Duration(days: 13 - index));
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isCompletedOn(DateTime day) {
    return widget.habit.completedDates.any((d) => _isSameDay(d, day));
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        widget.habit.completedDates.length >= widget.habit.totalDays;
    final progress =
        widget.habit.completedDates.length / widget.habit.totalDays;

    final currentStreak = widget.habit.getCurrentStreak();
    final alreadyDoneToday =
        widget.habit.lastCompletedDate != null &&
        widget.habit.lastCompletedDate!.year == DateTime.now().year &&
        widget.habit.lastCompletedDate!.month == DateTime.now().month &&
        widget.habit.lastCompletedDate!.day == DateTime.now().day;

    final gradientColors = isCompleted
        ? [Color(0xFF11998E), Color(0xFF38EF7D)]
        : [Color(0xFF667EEA), Color(0xFF764BA2)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientColors[0].withOpacity(0.1),
              gradientColors[1].withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      _buildProgressCircle(
                        progress,
                        isCompleted,
                        gradientColors,
                      ),
                      SizedBox(height: 40),
                      _buildStatsCard(isCompleted),
                      SizedBox(height: 32),
                      Text(
                        "Last 14 Days",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildCalendarView(),
                      SizedBox(height: 32),
                      _buildMarkDoneButton(
                        isCompleted,
                        alreadyDoneToday,
                        gradientColors,
                      ),
                      SizedBox(height: 16),
                      _buildSecondaryActions(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    final days = last14Days;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        final done = _isCompletedOn(day);

        return Container(
          decoration: BoxDecoration(
            color: done ? Colors.green : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "${day.day}",
              style: TextStyle(
                color: done ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
              color: Colors.grey[800],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.habit.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildProgressCircle(
    double progress,
    bool isCompleted,
    List<Color> gradientColors,
  ) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 14,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[200]!),
                ),
              ),
              // Progress circle with gradient effect
              SizedBox(
                width: 220,
                height: 220,
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: progress),
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 14,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      gradientColors[0],
                    ),
                  ),
                ),
              ),
              // Center content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCompleted)
                    Icon(
                      Icons.celebration_outlined,
                      size: 48,
                      color: gradientColors[0],
                    ),
                  SizedBox(height: isCompleted ? 8 : 0),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: gradientColors,
                    ).createShader(bounds),
                    child: Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.habit.completedDates.length} / ${widget.habit.totalDays} days',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isCompleted) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'COMPLETED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(bool isCompleted) {
    final daysRemaining =
        widget.habit.totalDays - widget.habit.completedDates.length;
    final streakPercentage =
        ((widget.habit.completedDates.length / widget.habit.totalDays) * 100)
            .toStringAsFixed(1);
    final currentStreak = widget.habit.getCurrentStreak();

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.local_fire_department,
              '$currentStreak',
              'Streak',
              Colors.red,
            ),
          ),
          Container(width: 1, height: 60, color: Colors.grey[200]),
          Expanded(
            child: _buildStatItem(
              Icons.check_circle,
              '${widget.habit.completedDates.length}',
              'Days Done',
              Colors.orange,
            ),
          ),
          Container(width: 1, height: 60, color: Colors.grey[200]),
          Expanded(
            child: _buildStatItem(
              isCompleted ? Icons.emoji_events : Icons.flag,
              isCompleted ? '100%' : '$daysRemaining',
              isCompleted ? 'Success!' : 'Remaining',
              isCompleted ? Colors.amber : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkDoneButton(
    bool isCompleted,
    bool alreadyDoneToday,
    List<Color> gradientColors,
  ) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[400]!])
            : LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isCompleted
            ? []
            : [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCompleted
              ? null
              : () {
                  widget.markDayDone(widget.habit.id);
                  setState(() {});
                  if (widget.habit.completedDays + 1 >=
                      widget.habit.totalDays) {
                    _triggerCelebration();
                  }
                },
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  isCompleted
                      ? 'COMPLETED!'
                      : alreadyDoneToday
                      ? 'Done for Today'
                      : 'Mark Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.refresh,
            label: 'Reset',
            color: Colors.blue,
            onTap: () {
              _showResetDialog(context);
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: Colors.red,
            onTap: () {
              _showDeleteDialog(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.refresh, color: Colors.blue),
              SizedBox(width: 12),
              Text('Reset Streak?'),
            ],
          ),
          content: Text(
            'This will reset your progress back to 0. Are you sure?',
            style: TextStyle(color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                widget.resetStreak(widget.habit.id);
                setState(() {});
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Reset', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete Habit?'),
            ],
          ),
          content: Text(
            'This will permanently delete this habit and all its progress.',
            style: TextStyle(color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                widget.deleteHabit(widget.habit.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
