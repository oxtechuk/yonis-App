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
import '../../../../app/widgets/app_skeleton.dart';
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
  bool _loginPushing = false;
  bool _autoLoginAttempted = false;

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
    // Fast path: already logged in this run — no storage read, no flash.
    if (AuthState.instance.isLoggedIn) {
      if (!mounted) return;
      setState(() {
        _checkingAuth = false;
        _loggedIn = true;
      });
      if (mounted) context.read<SessionsCubit>().load();
      return;
    }
    String? token;
    try {
      token = await getIt<SecureStorage>().read(SecureStorageKeys.accessToken);
    } catch (_) {
      token = null;
    }
    if (!mounted) return;
    final loggedIn = token != null && token.trim().isNotEmpty;
    setState(() {
      _checkingAuth = false;
      _loggedIn = loggedIn;
    });
    if (loggedIn) {
      // The in-memory flag is lost on restart while the token persists —
      // sync it so the rest of the app sees the restored session.
      AuthState.instance.login();
      if (mounted) context.read<SessionsCubit>().load();
    } else if (!_autoLoginAttempted) {
      // First unauthenticated visit: open login directly from here so we
      // don't flash the sessions skeleton in _buildBody first.
      _autoLoginAttempted = true;
      _redirectToLogin();
    }
  }

  Future<void> _goToLogin({bool leaveOnCancel = false}) async {
    // Push login on top of this tab. On success LoginForm pops back here,
    // then we re-check auth + reload bookings.
    await context.push(AppRoutes.login);
    if (!mounted) return;
    // Auto-push was cancelled (back button): pop this gated tab as well so
    // the user lands back on the screen they came from (home) instead of
    // an empty gate. Manual logins from the gate button stay put.
    if (leaveOnCancel && !AuthState.instance.isLoggedIn) {
      String? token;
      try {
        token =
            await getIt<SecureStorage>().read(SecureStorageKeys.accessToken);
      } catch (_) {
        token = null;
      }
      if (!mounted) return;
      if (token == null || token.trim().isEmpty) {
        context.go(AppRoutes.home);
        return;
      }
    }
    setState(() => _checkingAuth = true);
    await _checkAuthAndLoad();
  }

  /// Auto login push for the first unauthenticated visit. On cancel it
  /// leaves this tab (pop back to the previous screen) instead of showing
  /// the gate.
  void _redirectToLogin() {
    if (_loginPushing) return;
    _loginPushing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!mounted) return;
        await _goToLogin(leaveOnCancel: true);
      } finally {
        // Plain bool (no setState): must reset even when unmounted or on
        // error, otherwise the next visit sticks on the empty SizedBox
        // (white page) instead of the gate.
        _loginPushing = false;
      }
    });
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
        // Auth gate here (not inside _buildBody) so the sessions header +
        // tabs never flash before the login redirect when logged out.
        body: SafeArea(child: _buildContent()),
      ),
    );
  }

  Widget _buildContent() {
    if (_checkingAuth) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_loggedIn) {
      // The auto-push of the login route (first visit) covers this while
      // open; if it is dismissed the gate stays visible so the tab never
      // renders blank.
      return LoginRequiredView(
        message: context.tr(LocaleKeys.sessions_loginRequired),
        loginLabel: context.tr(LocaleKeys.auth_loginButton),
        onLogin: _goToLogin,
      );
    }
    return BlocListener<CancelBookingCubit, CancelBookingState>(
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
      // Token lookup, not sessions loading: neutral loader so it doesn't
      // look like sessions content flashing before the login redirect.
      return const Center(child: CircularProgressIndicator());
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
          SessionsInitial() || SessionsLoading() =>
            const SessionListSkeleton(),
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
