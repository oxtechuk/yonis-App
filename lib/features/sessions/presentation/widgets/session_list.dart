import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../models/session.dart';
import 'session_card.dart';

class SessionList extends StatelessWidget {
  const SessionList({
    super.key,
    required this.sessions,
    this.showActions = false,
    this.cancellingId,
    this.onCancelSession,
  });

  final List<Session> sessions;
  final bool showActions;

  /// Id of the booking currently being cancelled (spinner on its card).
  final String? cancellingId;

  /// Called with the booking id when a card's cancel button is tapped.
  final ValueChanged<String>? onCancelSession;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          context.tr(LocaleKeys.sessions_empty),
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) {
        final session = sessions[i];
        return SessionCard(
          session: session,
          showActions: showActions,
          isCancelling: cancellingId != null && cancellingId == session.id,
          onCancel: onCancelSession == null || session.id.isEmpty
              ? null
              : () => onCancelSession!(session.id),
        );
      },
    );
  }
}
