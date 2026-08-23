enum SessionStatus { upcoming, completed, cancelled }

class Session {
  const Session({
    required this.title,
    required this.doctor,
    required this.date,
    required this.time,
    required this.duration,
    required this.status,
    required this.statusLabel,
  });

  final String title;
  final String doctor;
  final String date;
  final String time;
  final String duration;
  final SessionStatus status;
  final String statusLabel;
}
