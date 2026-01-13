class Habit {
  final String id;
  final String name;
  final DateTime startDate;
  final int totalDays;
  int completedDays;
  DateTime? lastCompletedDate;
  // for the calender view
  List<DateTime> completedDates;

  Habit({
    required this.name,
    required this.id,
    required this.startDate,
    required this.totalDays,
    required this.completedDays,
    required this.lastCompletedDate,
    required this.completedDates,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name' : name,
      'startDate' : startDate.toIso8601String(),
      'totalDays' : totalDays,
      'completedDays' : completedDates.length,
      'lastCompletedDate' : lastCompletedDate?.toIso8601String(),
      'completedDates' : completedDates.map((d) => d.toIso8601String()).toList()
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map){
    List<DateTime> dates = [];

    if(map['completedDates'] != null){
      dates = (map['completedDates'] as List).map((d) => DateTime.parse(d)).toList();

    }else{
      int count = map['completedDays'] ?? 0;
      DateTime start = DateTime.parse(map['startDate']);
      for(int i = 0; i < count; i++){
        dates.add(start.add(Duration(days: i)));
      }
    }
    return Habit(
      id: map['id'],
      name: map['name'],
      startDate: DateTime.parse(map['startDate']),
      totalDays: map['totalDays'],
      completedDays:dates.length,
      lastCompletedDate: map['lastCompletedDate'] == null ? null : DateTime.parse(map['lastCompletedDate']),
      completedDates: dates,
    );
  }

  

  int getCurrentStreak(){
    if(completedDates.isEmpty) return 0;

    bool _isSameDay(DateTime a, DateTime b){
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

    final dates = [...completedDates];
    dates.sort((a,b) => a.compareTo(b));

    int streak = 0;

    DateTime today = DateTime.now();

    // nomalizing the data
    // removing time part
    DateTime currentDay = DateTime(today.year, today.month, today.day);

    while(true){
      bool found = dates.any((d) => _isSameDay(d, currentDay));

      if(found){
        streak++;
        currentDay = currentDay.subtract(Duration(days: 1));
      }else break;
    }
      return streak;
  }
}