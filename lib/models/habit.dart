class Habit {
  final String id;
  final String name;
  final DateTime startDate;
  final int totalDays;
  int completedDays;

  Habit({
    required this.name,
    required this.id,
    required this.startDate,
    required this.totalDays,
    required this.completedDays,
  });
}