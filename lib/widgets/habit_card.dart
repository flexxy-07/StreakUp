import 'package:flutter/material.dart';
import 'package:streakup/models/habit.dart';

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

    return Scaffold(
      body: Container(
        color: Color(0xFFFAFAFC),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      _buildProgressCircle(progress, isCompleted),
                      SizedBox(height: 40),
                      _buildStatsCard(isCompleted, currentStreak),
                      SizedBox(height: 32),
                      Text(
                        "Last 14 Days",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildCalendarView(),
                      SizedBox(height: 32),
                      _buildMarkDoneButton(isCompleted, alreadyDoneToday),
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
        final isToday = _isSameDay(day, DateTime.now());

        return Container(
          decoration: BoxDecoration(
            color: done ? Color(0xFF10B981) : Colors.white,
            border: isToday ? Border.all(color: Color(0xFF5B4EF5), width: 2) : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${day.day}",
                  style: TextStyle(
                    color: done ? Colors.white : Color(0xFF1F2937),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (done)
                  Icon(Icons.check, color: Colors.white, size: 12),
              ],
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
              color: Color(0xFF1F2937),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.habit.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(double progress, bool isCompleted) {
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
              color: Color(0xFF5B4EF5).withOpacity(0.2),
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
                  strokeWidth: 12,
                  backgroundColor: Color(0xFFF3F4F6),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                ),
              ),
              // Progress circle
              SizedBox(
                width: 220,
                height: 220,
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: progress),
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Color(0xFF10B981) : Color(0xFF5B4EF5),
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
                      color: Color(0xFF10B981),
                    ),
                  SizedBox(height: isCompleted ? 8 : 0),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.habit.completedDates.length} / ${widget.habit.totalDays} days',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (isCompleted) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981).withOpacity(0.1),
                        border: Border.all(color: Color(0xFF10B981), width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'COMPLETED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                          letterSpacing: 1.0,
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

  Widget _buildStatsCard(bool isCompleted, int currentStreak) {
    final daysRemaining =
        widget.habit.totalDays - widget.habit.completedDates.length;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: Offset(0, 8),
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
              'Current',
              'Streak',
              Color(0xFFEF4444),
            ),
          ),
          Container(width: 1, height: 70, color: Color(0xFFE5E7EB)),
          Expanded(
            child: _buildStatItem(
              Icons.check_circle,
              '${widget.habit.completedDates.length}',
              'Days',
              'Done',
              Color(0xFF10B981),
            ),
          ),
          Container(width: 1, height: 70, color: Color(0xFFE5E7EB)),
          Expanded(
            child: _buildStatItem(
              isCompleted ? Icons.emoji_events : Icons.flag,
              isCompleted ? 'Goal' : '$daysRemaining',
              isCompleted ? 'Achieved' : 'To Go',
              isCompleted ? 'Achieved' : 'Remaining',
              isCompleted ? Color(0xFFF59E0B) : Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label1,
    String label2,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 2),
        Column(
          children: [
            Text(
              label1,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              label2,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarkDoneButton(bool isCompleted, bool alreadyDoneToday) {
    final buttonColor = isCompleted
        ? Color(0xFF10B981)
        : alreadyDoneToday
            ? Color(0xFFF59E0B)
            : Color(0xFF5B4EF5);

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
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
                  if (widget.habit.completedDates.length >=
                      widget.habit.totalDays) {
                    _triggerCelebration();
                  }
                },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 26,
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
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
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
            color: Color(0xFF3B82F6),
            onTap: () {
              _showResetDialog(context);
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: Color(0xFFEF4444),
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
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
          backgroundColor: Color(0xFFFAFAFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.refresh, color: Color(0xFF3B82F6), size: 24),
              ),
              SizedBox(width: 12),
              Text(
                'Reset Streak?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Text(
            'This will reset your progress back to 0. Are you sure?',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                widget.resetStreak(widget.habit.id);
                setState(() {});
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Reset',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
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
          backgroundColor: Color(0xFFFAFAFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
              ),
              SizedBox(width: 12),
              Text(
                'Delete Habit?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Text(
            'This will permanently delete this habit and all its progress.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                widget.deleteHabit(widget.habit.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
