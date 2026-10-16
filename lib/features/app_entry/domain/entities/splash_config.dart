import 'package:equatable/equatable.dart';

class SplashConfig extends Equatable {
  const SplashConfig({
    required this.isEnabled,
    required this.durationSeconds,
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  final bool isEnabled;
  final int durationSeconds;
  final String title;
  final String subtitle;
  final String? imageUrl;

  Duration get duration =>
      Duration(seconds: durationSeconds > 0 ? durationSeconds : 3);

  @override
  List<Object?> get props => [
        isEnabled,
        durationSeconds,
        title,
        subtitle,
        imageUrl,
      ];
}
