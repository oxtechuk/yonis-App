import 'package:equatable/equatable.dart';

/// A bookable time range for a service on a given day, e.g. 09:00–09:30.
class TimeSlot extends Equatable {
  const TimeSlot({required this.start, required this.end});

  /// 24-hour "HH:mm" start time, as returned by the backend.
  final String start;

  /// 24-hour "HH:mm" end time, as returned by the backend.
  final String end;

  /// Arabic 12-hour label for [start], e.g. "٩:٠٠ ص".
  String get displayStart => _to12Hour(start);

  /// Arabic 12-hour label for [end], e.g. "٩:٣٠ ص".
  String get displayEnd => _to12Hour(end);

  /// Full range label, e.g. "٩:٠٠ ص - ٩:٣٠ ص".
  String get displayRange => '$displayStart - $displayEnd';

  /// English 12-hour "hh:mm AM/PM" label for [start], as the checkout API
  /// expects (e.g. "09:00 AM").
  String get apiStartTime => _to12HourEnglish(start);

  static const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  static String _toArabicDigits(String input) =>
      input.split('').map((c) {
        final digit = int.tryParse(c);
        return digit == null ? c : _arabicDigits[digit];
      }).join();

  static (int hour12, String minute, bool isPm)? _split12Hour(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) return null;
    final hour24 = int.tryParse(parts[0]);
    if (hour24 == null) return null;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return (hour12, parts[1], hour24 >= 12);
  }

  static String _to12Hour(String time24) {
    final split = _split12Hour(time24);
    if (split == null) return time24;
    final (hour12, minute, isPm) = split;
    final period = isPm ? 'م' : 'ص';
    return '${_toArabicDigits('$hour12:$minute')} $period';
  }

  static String _to12HourEnglish(String time24) {
    final split = _split12Hour(time24);
    if (split == null) return time24;
    final (hour12, minute, isPm) = split;
    final period = isPm ? 'PM' : 'AM';
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  List<Object?> get props => [start, end];
}
