import '../../domain/entities/time_slot.dart';

class SlotsResponseDto {
  const SlotsResponseDto({required this.success, required this.slots});

  factory SlotsResponseDto.fromJson(Map<String, dynamic> json) {
    final list = json['slots'];
    return SlotsResponseDto(
      success: json['success'] as bool? ?? false,
      slots: list is List<dynamic>
          ? list
              .whereType<Map<String, dynamic>>()
              .map(TimeSlotDto.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final bool success;
  final List<TimeSlotDto> slots;
}

class TimeSlotDto {
  const TimeSlotDto({required this.start, required this.end});

  factory TimeSlotDto.fromJson(Map<String, dynamic> json) {
    return TimeSlotDto(
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
    );
  }

  final String start;
  final String end;

  TimeSlot toEntity() => TimeSlot(start: start, end: end);
}
