import '../../domain/entities/home_slider.dart';

class SlidersResponseDto {
  const SlidersResponseDto({
    required this.sliders,
  });

  factory SlidersResponseDto.fromJson(Map<String, dynamic> json) {
    final rawList = json['sliders'] ?? json['data'];
    final sliders = _parseSliderList(rawList);
    return SlidersResponseDto(sliders: sliders);
  }

  static List<SliderDto> _parseSliderList(dynamic jsonList) {
    if (jsonList is! List<dynamic>) return const [];
    final list = jsonList
        .whereType<Map<String, dynamic>>()
        .map(SliderDto.fromJson)
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List.unmodifiable(list);
  }

  final List<SliderDto> sliders;
}

class SliderDto {
  const SliderDto({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actionType,
    required this.actionValue,
    required this.sortOrder,
  });

  factory SliderDto.fromJson(Map<String, dynamic> json) {
    return SliderDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: _readString(json, 'title') ?? '',
      subtitle: _readString(json, 'subtitle') ?? '',
      imageUrl: _readString(json, 'image_url') ?? '',
      actionType: _readString(json, 'action_type') ?? '',
      actionValue: json['action_value']?.toString().trim() ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String actionType;
  final String actionValue;
  final int sortOrder;

  HomeSlider toEntity() => HomeSlider(
        id: id,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        actionType: actionType,
        actionValue: actionValue,
        sortOrder: sortOrder,
      );
}
