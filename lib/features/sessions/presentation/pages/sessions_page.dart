import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../../../app/widgets/app_toast.dart';
import '../../../../app/widgets/login_required_view.dart';
import '../../../../app/widgets/primary_button.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/domain/auth_state.dart';
import '../../domain/entities/patient_booking.dart';
import '../cubit/cancel_booking_cubit.dart';
import '../cubit/sessions_cubit.dart';
import '../models/session.dart';
import '../widgets/session_list.dart';
import '../widgets/sessions_header.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionsCubit>(create: (_) => getIt<SessionsCubit>()),
        BlocProvider<CancelBookingCubit>(
          create: (_) => getIt<CancelBookingCubit>(),
        ),
      ],
      child: const _SessionsView(),
    );
  }
}

class _SessionsView extends StatefulWidget {
  const _SessionsView();

  @override
  State<_SessionsView> createState() => _SessionsViewState();
}

class _SessionsViewState extends State<_SessionsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _checkingAuth = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAuthAndLoad();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// The backend requires a logged-in patient: the access token persisted
  /// at login is attached to `GET /api/patient/bookings` automatically by
  /// [AuthInterceptor]. Without a token there is nothing to fetch, so the
  /// sign-in gate is shown instead of firing an unauthenticated request.
  Future<void> _checkAuthAndLoad() async {
    String? token;
    try {
      token = await getIt<SecureStorage>().read(SecureStorageKeys.accessToken);
    } catch (_) {
      token = null;
    }
    if (!mounted) return;
    final loggedIn =
        (token != null && token.trim().isNotEmpty) ||
        AuthState.instance.isLoggedIn;
    setState(() {
      _checkingAuth = false;
      _loggedIn = loggedIn;
    });
    if (loggedIn) {
      // The in-memory flag is lost on restart while the token persists —
      // sync it so the rest of the app sees the restored session.
      AuthState.instance.login();
      if (mounted) context.read<SessionsCubit>().load();
    }
  }

  Future<void> _goToLogin() async {
    await context.push(AppRoutes.login);
    if (!mounted) return;
    setState(() => _checkingAuth = true);
    await _checkAuthAndLoad();
  }

  List<Session> _toSessions(
    BuildContext context,
    List<PatientBooking> bookings,
  ) => bookings.map((b) => _toSession(context, b)).toList(growable: false);

  Session _toSession(BuildContext context, PatientBooking booking) {
    final status = switch (booking.status) {
      BookingStatus.completed => SessionStatus.completed,
      BookingStatus.cancelled => SessionStatus.cancelled,
      BookingStatus.upcoming => SessionStatus.upcoming,
    };
    final statusLabel = switch (booking.status) {
      BookingStatus.completed => context.tr(
        LocaleKeys.sessions_statusCompleted,
      ),
      BookingStatus.cancelled => context.tr(
        LocaleKeys.sessions_statusCancelled,
      ),
      BookingStatus.upcoming => context.tr(LocaleKeys.sessions_statusUpcoming),
    };
    return Session(
      id: booking.id,
      title: booking.title.isEmpty
          ? context.tr(LocaleKeys.sessions_cardTitle)
          : booking.title,
      doctor: booking.doctorName.isEmpty
          ? context.tr(LocaleKeys.sessions_doctorName)
          : booking.doctorName,
      date: booking.date.isEmpty ? '–' : booking.date,
      time: booking.time.isEmpty ? '–' : booking.time,
      duration: _durationLabel(context, booking.duration),
      status: status,
      statusLabel: statusLabel,
    );
  }

  /// The backend sends a bare minute count (`service.duration: 30`);
  /// render it with the localized unit ("30 min" / "30 دقيقة").
  /// Already-suffixed values pass through untouched.
  String _durationLabel(BuildContext context, String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '–';
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(trimmed)) {
      final count = trimmed.contains('.')
          ? trimmed
          : (int.tryParse(trimmed)?.toString() ?? trimmed);
      return context.tr(
        LocaleKeys.home_bookService_minutesShort,
        namedArgs: {'count': count},
      );
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocListener<CancelBookingCubit, CancelBookingState>(
            listener: (context, state) {
              switch (state) {
                case CancelBookingSuccess(:final message):
                  AppToast.show(
                    context,
                    message ?? context.tr(LocaleKeys.sessions_cancelSuccess),
                  );
                  context.read<SessionsCubit>().load();
                case CancelBookingFailure(:final failure):
                  AppToast.show(context, failure.message);
                case CancelBookingInitial() || CancelBookingInProgress():
                  break;
              }
            },
            child: Column(
              // start = right in RTL, matches design
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SessionsHeader(),
                const SizedBox(height: AppSpacing.md),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: AppTextStyles.body,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2,
                  tabs: [
                    Tab(text: context.tr(LocaleKeys.sessions_tabUpcoming)),
                    Tab(text: context.tr(LocaleKeys.sessions_tabCompleted)),
                    Tab(text: context.tr(LocaleKeys.sessions_tabCancelled)),
                  ],
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Asks for confirmation, then cancels via
  /// `POST /api/booking/{id}/cancel`. The list refresh is driven by the
  /// [CancelBookingCubit] listener above, not here.
  Future<void> _confirmAndCancel(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          dialogContext.tr(LocaleKeys.sessions_cancelDialogTitle),
          textAlign: TextAlign.center,
        ),
        content: Text(
          dialogContext.tr(LocaleKeys.sessions_cancelDialogMessage),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr(LocaleKeys.common_cancel)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              dialogContext.tr(LocaleKeys.sessions_cancelDialogConfirm),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<CancelBookingCubit>().cancel(bookingId: bookingId);
    }
  }

  Widget _buildBody() {
    if (_checkingAuth) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (!_loggedIn) {
      return LoginRequiredView(
        message: context.tr(LocaleKeys.sessions_loginRequired),
        loginLabel: context.tr(LocaleKeys.auth_loginButton),
        onLogin: _goToLogin,
      );
    }
    return BlocBuilder<SessionsCubit, SessionsState>(
      builder: (context, state) {
        return switch (state) {
          SessionsInitial() || SessionsLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          SessionsUnauthorized() => LoginRequiredView(
            message: context.tr(LocaleKeys.sessions_loginRequired),
            loginLabel: context.tr(LocaleKeys.auth_loginButton),
            onLogin: _goToLogin,
          ),
          SessionsError(:final failure) => _SessionsErrorView(
            message: failure.message,
            onRetry: () => context.read<SessionsCubit>().load(),
          ),
          SessionsLoaded(:final upcoming, :final completed, :final cancelled) =>
            _buildTabs(context, upcoming, completed, cancelled),
        };
      },
    );
  }

  Widget _buildTabs(
    BuildContext context,
    List<PatientBooking> upcoming,
    List<PatientBooking> completed,
    List<PatientBooking> cancelled,
  ) {
    final cancelState = context.watch<CancelBookingCubit>().state;
    final cancellingId = cancelState is CancelBookingInProgress
        ? cancelState.bookingId
        : null;
    return TabBarView(
      controller: _tabController,
      children: [
        _RefreshableList(
          sessions: _toSessions(context, upcoming),
          showActions: true,
          cancellingId: cancellingId,
          onCancelSession: _confirmAndCancel,
          onRefresh: () => context.read<SessionsCubit>().load(),
        ),
        _RefreshableList(
          sessions: _toSessions(context, completed),
          cancellingId: cancellingId,
          onCancelSession: _confirmAndCancel,
          onRefresh: () => context.read<SessionsCubit>().load(),
        ),
        _RefreshableList(
          sessions: _toSessions(context, cancelled),
          cancellingId: cancellingId,
          onCancelSession: _confirmAndCancel,
          onRefresh: () => context.read<SessionsCubit>().load(),
        ),
      ],
    );
  }
}

/// Pull-to-refresh wrapper. The empty view of [SessionList] is not
/// scrollable, so it is shown as-is without a [RefreshIndicator].
class _RefreshableList extends StatelessWidget {
  const _RefreshableList({
    required this.sessions,
    required this.onRefresh,
    this.showActions = false,
    this.cancellingId,
    this.onCancelSession,
  });

  final List<Session> sessions;
  final Future<void> Function() onRefresh;
  final bool showActions;
  final String? cancellingId;
  final ValueChanged<String>? onCancelSession;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return SessionList(
        sessions: sessions,
        showActions: showActions,
        cancellingId: cancellingId,
        onCancelSession: onCancelSession,
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: SessionList(
        sessions: sessions,
        showActions: showActions,
        cancellingId: cancellingId,
        onCancelSession: onCancelSession,
      ),
    );
  }
}

class _SessionsErrorView extends StatelessWidget {
  const _SessionsErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: context.tr(LocaleKeys.common_retry),
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
