/// Booking status normalized from the various raw status strings the
/// backend may return (`pending`, `confirmed`, `completed`, `cancelled`, ...).
enum BookingStatus { upcoming, completed, cancelled }

extension BookingStatusExt on BookingStatus {
  /// Value of the `?tab=` query parameter of `GET /api/patient/bookings`.
  String get apiTab => switch (this) {
        BookingStatus.upcoming => 'upcoming',
        BookingStatus.completed => 'completed',
        BookingStatus.cancelled => 'cancelled',
      };
}

/// A single patient booking from `GET /api/patient/bookings`.
///
/// Display strings are raw backend values (service/doctor names, dates);
/// the UI falls back to localized copy when a field is missing.
class PatientBooking {
  const PatientBooking({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.duration,
    required this.status,
    required this.rawStatus,
  });

  final String id;
  final String title;
  final String doctorName;
  final String date;
  final String time;
  final String duration;
  final BookingStatus status;

  /// The untouched backend status string (useful for debugging).
  final String rawStatus;
}
