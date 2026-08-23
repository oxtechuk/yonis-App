import 'package:flutter/material.dart';

import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../models/session.dart';
import '../widgets/session_list.dart';
import '../widgets/sessions_header.dart';

const _mockSessions = <Session>[
  Session(
    title: 'جلسة استشارة نفسية',
    doctor: 'د. يونس',
    date: '15 أكتوبر 2023',
    time: '10:00 صباحاً',
    duration: '45 دقيقة',
    status: SessionStatus.upcoming,
    statusLabel: 'قيد الانتظار',
  ),
  Session(
    title: 'جلسة استشارة نفسية',
    doctor: 'د. يونس',
    date: '3 سبتمبر 2023',
    time: '11:00 صباحاً',
    duration: '45 دقيقة',
    status: SessionStatus.completed,
    statusLabel: 'مكتملة',
  ),
  Session(
    title: 'جلسة استشارة نفسية',
    doctor: 'د. يونس',
    date: '20 أغسطس 2023',
    time: '9:00 صباحاً',
    duration: '45 دقيقة',
    status: SessionStatus.cancelled,
    statusLabel: 'ملغاة',
  ),
];

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Session> _filtered(SessionStatus status) => _mockSessions
      .where((s) => s.status == status)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
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
                tabs: const [
                  Tab(text: 'القادمة'),
                  Tab(text: 'المكتملة'),
                  Tab(text: 'الملغاة'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SessionList(
                      sessions: _filtered(SessionStatus.upcoming),
                      showActions: true,
                    ),
                    SessionList(sessions: _filtered(SessionStatus.completed)),
                    SessionList(sessions: _filtered(SessionStatus.cancelled)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
