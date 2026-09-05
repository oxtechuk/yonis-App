enum SessionStatus { upcoming, completed, cancelled }

class Session {
  const Session({
    this.id = '',
    required this.title,
    required this.doctor,
    required this.date,
    required this.time,
    required this.duration,
    required this.status,
    required this.statusLabel,
  });

  /// Backend booking id — empty for local/demo entries. Needed to target
  /// actions (cancel/reschedule) at the right booking.
  final String id;
  final String title;
  final String doctor;
  final String date;
  final String time;
  final String duration;
  final SessionStatus status;
  final String statusLabel;
}
