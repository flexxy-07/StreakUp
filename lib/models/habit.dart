class Habit {
  final String id;
  final String name;
  final DateTime startDate;
  final int totalDays;
  int completedDays;
  DateTime? lastCompletedDate;

  Habit({
    required this.name,
    required this.id,
    required this.startDate,
    required this.totalDays,
    required this.completedDays,
    required this.lastCompletedDate,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name' : name,
      'startDate' : startDate.toIso8601String(),
      'totalDays' : totalDays,
      'completedDays' : completedDays,
      'lastCompletedDate' : lastCompletedDate?.toIso8601String()
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map){
    return Habit(
      id: map['id'],
      name: map['name'],
      startDate: DateTime.parse(map['startDate']),
      totalDays: map['totalDays'],
      completedDays: map['completedDays'],
      lastCompletedDate: map['lastCompletedDate'] == null ? null : DateTime.parse(map['lastCompletedDate'])
    );
  }
}