class Subject {
  String subject;
  String type;
  String? teacher;
  //DateTime start;
  //DateTime end;
  String time;
  String place;
  String roomId;

  @override
  String toString() {
    return "$subject $type $teacher $time $place $roomId\n";
  }

  Subject({
    required this.subject,
    required this.type,
    required this.time,
    //required this.start,
    //required this.end,
    required this.place,
    required this.roomId,
  });
}
