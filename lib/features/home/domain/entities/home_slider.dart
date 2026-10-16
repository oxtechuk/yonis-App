import 'package:equatable/equatable.dart';

class HomeSlider extends Equatable {
  const HomeSlider({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actionType,
    required this.actionValue,
    required this.sortOrder,
  });

  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String actionType;
  final String actionValue;
  final int sortOrder;

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        imageUrl,
        actionType,
        actionValue,
        sortOrder,
      ];
}
