import 'dart:async';

import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

/// Lightweight in-app toast rendered as a top-center overlay.
///
/// Used instead of native platform toasts because their positioning
/// cannot be reliably controlled across devices.
abstract final class AppToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = AppColors.error,
    Color textColor = AppColors.white,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    dismiss();
    _entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
    );
    overlay.insert(_entry!);
    _timer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  });

  final String message;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    // Ignore pointer so the toast never blocks taps underneath it.
    return Positioned.directional(
      textDirection: Directionality.of(context),
      top: MediaQuery.paddingOf(context).top + 12,
      start: 24,
      end: 24,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.body.copyWith(color: textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
