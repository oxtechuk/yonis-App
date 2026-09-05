import '../../../../core/error/app_exception.dart';
import '../../domain/entities/patient_booking.dart';

/// Decodes one booking of `GET /api/patient/bookings`.
///
/// The parser is intentionally tolerant: field names vary between backend
/// versions (`service_title` vs nested `service.name`, `start_time` vs
/// `appointment_time`, ...), so every field is read from a list of aliases
/// and defaults to an empty string instead of throwing. Only a completely
/// unrecognized envelope shape raises [SerializationException].
class PatientBookingDto {
  const PatientBookingDto({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.duration,
    required this.rawStatus,
  });

  factory PatientBookingDto.fromJson(Map<String, dynamic> json) {
    final service = _nested(json, 'service');
    final doctor =
        _nested(json, 'doctor') ?? _nested(json, 'consultant');
    final slot = _nested(json, 'slot');

    var date = _firstString(json, [
      'date',
      'booking_date',
      'appointment_date',
      'scheduled_date',
      'slot_date',
    ]);
    var time = _firstString(json, [
      'time',
      'start_time',
      'appointment_time',
      'scheduled_time',
      'slot_time',
    ]);

    // ISO datetimes (`scheduled_at: "2024-05-01T10:00:00"`) carry both.
    final scheduledAt = _firstString(json, [
      'scheduled_at',
      'appointment_at',
      'starts_at',
      'booked_at',
    ]);
    if ((date == null || time == null) &&
        scheduledAt != null &&
        scheduledAt.isNotEmpty) {
      final parts = scheduledAt.split(RegExp(r'[T ]'));
      date ??= parts.isNotEmpty ? parts[0] : null;
      if (time == null && parts.length > 1) {
        final clock = parts[1].split('.').first;
        time = clock.length >= 5 ? clock.substring(0, 5) : clock;
      }
    }
    if (slot != null) {
      date ??= _firstString(slot, ['date', 'day']);
      time ??= _firstString(slot, ['start_time', 'start', 'time', 'from']);
    }

    // Real payload notes:
    // - `date` is a full ISO datetime ("2026-10-15T00:00:00.000000Z") —
    //   only the calendar part is shown on the card.
    // - `start_time`/`end_time` are "HH:mm:ss" — trimmed to "HH:mm" and
    //   combined into a range ("10:00 - 10:30").
    var endTime = _firstString(json, [
      'end_time',
      'appointment_end_time',
      'ends_at',
      'end',
    ]);
    endTime ??= slot == null
        ? null
        : _firstString(slot, ['end_time', 'end', 'to']);
    date = _dateOnly(date);
    time = _clock(time);
    endTime = _clock(endTime);
    if (time != null && endTime != null && endTime.isNotEmpty) {
      time = '$time - $endTime';
    }

    final nestedTitle = service == null
        ? null
        : _firstString(service, ['title', 'name']);
    final nestedDoctor = doctor == null
        ? null
        : _firstString(doctor, ['name', 'full_name', 'title']);
    final nestedDuration = service == null
        ? null
        : _firstString(service, ['duration', 'duration_minutes']);

    return PatientBookingDto(
      id: _firstString(json, [
            'id',
            'booking_id',
            'booking_reference',
            'reference',
          ]) ??
          '',
      title: _firstString(json, [
            'service_title',
            'title',
            'consultation_title',
            'subject',
            'service_name',
          ]) ??
          nestedTitle ??
          '',
      doctorName: _firstString(json, [
            'doctor_name',
            'doctor',
            'consultant_name',
            'consultant',
            'therapist_name',
            'therapist',
          ]) ??
          nestedDoctor ??
          '',
      date: date ?? '',
      time: time ?? '',
      duration: _firstString(json, [
            'duration',
            'duration_minutes',
            'durationMinutes',
            'length',
            'session_duration',
          ]) ??
          nestedDuration ??
          '',
      rawStatus: _firstString(json, [
            'status',
            'booking_status',
            'state',
            'current_status',
          ]) ??
          'pending',
    );
  }

  final String id;
  final String title;
  final String doctorName;
  final String date;
  final String time;
  final String duration;
  final String rawStatus;

  PatientBooking toEntity() => PatientBooking(
        id: id,
        title: title,
        doctorName: doctorName,
        date: date,
        time: time,
        duration: duration,
        status: normalizeStatus(rawStatus),
        rawStatus: rawStatus,
      );

  /// Maps backend status strings onto the three UI tabs.
  ///
  /// Real statuses seen so far: `AwaitingPayment` (upcoming — the booking
  /// waits for payment), plus the usual `pending/confirmed/completed/
  /// cancelled` family. Anything unrecognized stays upcoming so a new
  /// backend status never silently disappears from the list.
  static BookingStatus normalizeStatus(String raw) {
    final s = raw.trim().toLowerCase();
    const cancelled = [
      'cancel',
      'cancelled',
      'canceled',
      'rejected',
      'declined',
      'refunded',
      'no_show',
      'noshow',
      'ملغ',
    ];
    const completed = [
      'complet',
      'done',
      'finish',
      'attended',
      'closed',
      'مكتمل',
      'منته',
    ];
    if (cancelled.any(s.contains)) return BookingStatus.cancelled;
    if (completed.any(s.contains)) return BookingStatus.completed;
    return BookingStatus.upcoming;
  }

  /// Accepts every envelope the backend may wrap the list in:
  /// a bare list, `{data: [...]}`, paginated `{data: {data: [...]}}`,
  /// or `{bookings|items|results: [...]}`.
  static List<PatientBookingDto> listFromJson(dynamic json) {
    final list = _extractList(json);
    if (list == null) {
      throw const SerializationException(
        message: 'Unexpected response shape for patient bookings.',
      );
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(PatientBookingDto.fromJson)
        .toList(growable: false);
  }

  static List<dynamic>? _extractList(dynamic json) {
    if (json is List) return json;
    if (json is Map<String, dynamic>) {
      for (final key in ['data', 'bookings', 'items', 'results']) {
        final value = json[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          final nested = value['data'];
          if (nested is List) return nested;
        }
      }
    }
    return null;
  }

  static Map<String, dynamic>? _nested(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    return value is Map<String, dynamic> ? value : null;
  }

  /// "2026-10-15T00:00:00.000000Z" -> "2026-10-15".
  static String? _dateOnly(String? value) {
    if (value == null || value.isEmpty) return value;
    final t = value.indexOf('T');
    if (t > 0) return value.substring(0, t);
    return value;
  }

  /// "10:00:00" -> "10:00"; "10:00" stays "10:00".
  static String? _clock(String? value) {
    if (value == null || value.isEmpty) return value;
    var clock = value;
    if (clock.contains('T')) {
      final parts = clock.split(RegExp(r'[T ]'));
      if (parts.length > 1) clock = parts[1].split('.').first;
    }
    final match = RegExp(r'^(\d{1,2}:\d{2})').firstMatch(clock);
    return match?.group(1) ?? clock;
  }

  static String? _firstString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value is num) return value.toString();
    }
    return null;
  }
}
