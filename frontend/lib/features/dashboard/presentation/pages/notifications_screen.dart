import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/core/api/uni_api_service.dart';
import 'package:uni_sphere/core/models/event_models.dart';
import 'package:uni_sphere/core/services/saved_events_provider.dart';
import 'package:uni_sphere/core/widgets/dash_widgets.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final IconData icon;
  final DateTime at;
  final bool unread;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.at,
    this.unread = true,
  });
}

List<AppNotification> buildCampusNotifications({
  required List<EventModel> events,
  required List<RegistrationModel> regs,
  required List<EventModel> saved,
}) {
  final items = <AppNotification>[];
  final now = DateTime.now();

  for (final r in regs.where((r) => r.status != 'cancelled')) {
    items.add(
      AppNotification(
        id: 'reg-${r.id}',
        title: 'Registration confirmed',
        body: 'You’re in for ${r.eventTitle}. Open QR Passport for your pass.',
        icon: Icons.check_circle_outline_rounded,
        at: DateTime.tryParse(r.createdAt ?? '') ?? now,
      ),
    );
  }

  for (final e in events.take(5)) {
    final prize = (e.cashPrize ?? '').trim();
    items.add(
      AppNotification(
        id: 'up-${e.id}',
        title: e.title,
        body: prize.isNotEmpty
            ? '${e.description} Prize: $prize'
            : e.description,
        icon: Icons.event_available_rounded,
        at: DateTime.tryParse(e.date) ?? now,
      ),
    );
  }

  for (final e in saved.take(3)) {
    items.add(
      AppNotification(
        id: 'saved-${e.id}',
        title: 'Saved reminder',
        body: '${e.title} is on your list — ${e.formattedDate}.',
        icon: Icons.favorite_border_rounded,
        at: now.subtract(const Duration(hours: 2)),
        unread: false,
      ),
    );
  }

  if (items.isEmpty) {
    items.add(
      AppNotification(
        id: 'welcome',
        title: 'Welcome to UniSphere',
        body: 'Browse Discover to find campus events near you.',
        icon: Icons.campaign_outlined,
        at: now,
      ),
    );
  }

  items.sort((a, b) => b.at.compareTo(a.at));
  return items;
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _loading = true;
  List<AppNotification> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(uniApiProvider);
      final user = ref.read(authViewModelProvider).user;
      final events = filterEventsForUser(await api.getEvents(), user?.college);
      final regs = await api.getMyRegistrations();
      final saved = ref.read(savedEventsProvider);
      if (!mounted) return;
      setState(() {
        _items = buildCampusNotifications(
          events: events,
          regs: regs,
          saved: saved,
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = buildCampusNotifications(
          events: const [],
          regs: const [],
          saved: ref.read(savedEventsProvider),
        );
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashBg,
      appBar: AppBar(
        backgroundColor: AppColors.dashBg,
        foregroundColor: AppColors.dashText,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: AppTheme.fontBold,
            fontSize: 18,
            color: AppColors.dashText,
          ),
        ),
      ),
      body: _loading
          ? const DashLoading()
          : RefreshIndicator(
              color: AppColors.dashAccent,
              onRefresh: _load,
              child: _items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: 'No notifications',
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final n = _items[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.dashCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.dashBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.dashAccentSoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  n.icon,
                                  color: AppColors.dashAccentText,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: AppTheme.fontBold,
                                              fontSize: 14,
                                              color: AppColors.dashText,
                                            ),
                                          ),
                                        ),
                                        if (n.unread)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFF6B6B),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.dashMuted,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
