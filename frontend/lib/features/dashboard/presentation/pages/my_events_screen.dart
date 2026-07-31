import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/core/api/uni_api_service.dart';
import 'package:uni_sphere/core/models/event_models.dart';
import 'package:uni_sphere/core/services/saved_events_provider.dart';
import 'package:uni_sphere/core/widgets/dash_widgets.dart';
import 'package:uni_sphere/core/widgets/event_cover.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class MyEventsScreen extends ConsumerStatefulWidget {
  const MyEventsScreen({super.key});

  @override
  ConsumerState<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends ConsumerState<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _loading = true;
  List<RegistrationModel> _regs = [];
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final regs = await ref.read(uniApiProvider).getMyRegistrations();
      if (!mounted) return;
      setState(() {
        _regs = regs.where((r) => r.status != 'cancelled').toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _regs = [];
        _loading = false;
      });
    }
  }

  Future<void> _cancel(RegistrationModel reg) async {
    setState(() => _busyId = reg.id);
    try {
      await ref.read(uniApiProvider).cancelRegistration(reg.id);
      if (!mounted) return;
      setState(() {
        _regs.removeWhere((r) => r.id == reg.id);
        _busyId = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.mRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(savedEventsProvider);

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Events',
                style: TextStyle(
                  fontFamily: AppTheme.fontBold,
                  fontSize: 22,
                  color: AppColors.dashText,
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabs,
            labelColor: AppColors.dashAccent,
            unselectedLabelColor: AppColors.dashMuted,
            indicatorColor: AppColors.dashAccent,
            labelStyle: const TextStyle(fontFamily: AppTheme.fontBold),
            tabs: const [
              Tab(text: 'Registered'),
              Tab(text: 'Saved'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _loading
                    ? const DashLoading()
                    : RefreshIndicator(
                        color: AppColors.dashAccent,
                        onRefresh: _load,
                        child: _regs.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 80),
                                  EmptyState(
                                    icon: Icons.event_busy_outlined,
                                    title: 'No registered events',
                                    subtitle:
                                        'Browse Home or Discover to join.',
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 24),
                                itemCount: _regs.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final reg = _regs[i];
                                  final e = reg.event;
                                  final prize = (e?.cashPrize ?? '').trim();
                                  return DashCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reg.eventTitle,
                                          style: const TextStyle(
                                            fontFamily: AppTheme.fontBold,
                                            fontSize: 15,
                                            color: AppColors.dashText,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${e?.formattedDate ?? ''} · ${e?.location ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.dashMuted,
                                          ),
                                        ),
                                        if (prize.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            'Prize: $prize',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.dashAccentText,
                                              fontFamily: AppTheme.fontBold,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          'Pass: ${reg.passCode}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.dashAccentText,
                                            fontFamily: AppTheme.fontBold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: _busyId == reg.id
                                                ? null
                                                : () => _cancel(reg),
                                            child: Text(
                                              _busyId == reg.id
                                                  ? 'Cancelling…'
                                                  : 'Cancel registration',
                                              style: const TextStyle(
                                                color: AppColors.mRed,
                                                fontFamily: AppTheme.fontBold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                saved.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          EmptyState(
                            icon: Icons.favorite_border_rounded,
                            title: 'No saved events',
                            subtitle:
                                'Tap the heart on an event card to save it here.',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: saved.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final e = saved[i];
                          return EventImageCard(
                            event: e,
                            saved: true,
                            onToggleSave: () => ref
                                .read(savedEventsProvider.notifier)
                                .toggle(e),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
