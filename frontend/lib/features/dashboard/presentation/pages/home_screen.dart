import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uni_sphere/core/api/api_endpoints.dart';
import 'package:uni_sphere/core/api/uni_api_service.dart';
import 'package:uni_sphere/core/models/event_models.dart';
import 'package:uni_sphere/core/widgets/dash_widgets.dart';
import 'package:uni_sphere/core/widgets/event_cover.dart';
import 'package:uni_sphere/core/services/saved_events_provider.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/features/dashboard/presentation/pages/notifications_screen.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  /// 0 Home, 1 Discover, 2 My Events, 3 Passport, 4 Profile
  final void Function(int index)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _loading = true;
  List<EventModel> _feed = [];
  Set<String> _registeredIds = {};
  String? _busyId;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(uniApiProvider);
      final user = ref.read(authViewModelProvider).user;
      final events = await api.getEvents();
      List<RegistrationModel> regs = const [];
      try {
        regs = await api.getMyRegistrations();
      } catch (_) {}
      final filtered = filterEventsForUser(events, user?.college);
      final active = regs.where((r) => r.status != 'cancelled');
      if (!mounted) return;
      setState(() {
        _registeredIds = active
            .map((r) => r.event?.id ?? r.eventId ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();
        _feed = filtered;
        _loading = false;
        if (filtered.isEmpty && events.isNotEmpty) {
          _error = 'No events match your college filters yet.';
        } else if (events.isEmpty) {
          _error = 'No events from the server yet.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
        _feed = [];
      });
    }
  }

  Future<void> _register(EventModel event) async {
    setState(() => _busyId = event.id);
    try {
      final reg = await ref
          .read(uniApiProvider)
          .registerForEvent(event.id, event: event);
      final user = ref.read(authViewModelProvider).user;
      if (!mounted) return;
      setState(() {
        _registeredIds.add(event.id);
        _busyId = null;
      });
      await showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: AppColors.dashCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.dashBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Registration successful',
                  style: TextStyle(
                    fontFamily: AppTheme.fontBold,
                    fontSize: 16,
                    color: AppColors.dashText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  reg.eventTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.dashMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pass: ${reg.passCode}',
                  style: const TextStyle(
                    color: AppColors.dashAccentText,
                    fontFamily: AppTheme.fontBold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: QrImageView(
                    data: reg.qrValue(user?.id ?? user?.email ?? 'user'),
                    size: 150,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: AppColors.dashAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
    final user = ref.watch(authViewModelProvider).user;
    final savedIds =
        ref.watch(savedEventsProvider).map((e) => e.id).toSet();
    final firstName = user?.firstName ?? 'User';
    final photoUrl = ApiEndpoints.resolveMediaUrl(user?.profileImage);
    final recommended = _feed.take(8).toList();
    final hasPrize = recommended.any((e) => (e.cashPrize ?? '').isNotEmpty);

    return SafeArea(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: RefreshIndicator(
          color: AppColors.dashAccent,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: EdgeInsets.zero,
            children: [
              // Hero header — avatar before welcome + catchy line
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0E3A42),
                      Color(0xFF0A0A0A),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => widget.onNavigate?.call(4),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.dashAccentSoft,
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl.isEmpty
                                ? Text(
                                    firstName.isNotEmpty ? firstName[0] : 'U',
                                    style: const TextStyle(
                                      fontFamily: AppTheme.fontBold,
                                      color: AppColors.dashAccentText,
                                      fontSize: 18,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => widget.onNavigate?.call(3),
                          icon: const Icon(
                            Icons.qr_code_2_rounded,
                            color: AppColors.dashText,
                          ),
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const NotificationsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.dashText,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF6B6B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Welcome, $firstName!',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontRegular,
                        fontSize: 14,
                        color: AppColors.dashMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Find amazing\ncampus events',
                      style: TextStyle(
                        fontFamily: AppTheme.fontExtraBold,
                        fontSize: 28,
                        height: 1.15,
                        color: AppColors.dashText,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () => widget.onNavigate?.call(1),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.dashCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.dashBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search_rounded,
                                color: AppColors.dashMuted, size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search events…',
                                style: TextStyle(
                                  color: AppColors.dashMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(Icons.tune_rounded,
                                color: AppColors.dashMuted, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories — white card, circular tiles (icons unchanged)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _CatTile(
                        icon: Icons.sports_soccer,
                        label: 'Sports',
                        color: const Color(0xFFF97316),
                        onTap: () => widget.onNavigate?.call(1),
                      ),
                      _CatTile(
                        icon: Icons.celebration,
                        label: 'Cultural',
                        color: const Color(0xFFA855F7),
                        onTap: () => widget.onNavigate?.call(1),
                      ),
                      _CatTile(
                        icon: Icons.computer,
                        label: 'Tech',
                        color: const Color(0xFF3B82F6),
                        onTap: () => widget.onNavigate?.call(1),
                      ),
                      _CatTile(
                        icon: Icons.grid_view_rounded,
                        label: 'More',
                        color: const Color(0xFF22C55E),
                        onTap: () => widget.onNavigate?.call(1),
                      ),
                    ],
                  ),
                ),
              ),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: DashLoading(),
                )
              else ...[
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.dashMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),

                // Recommended — horizontal
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recommended for you',
                          style: TextStyle(
                            fontFamily: AppTheme.fontBold,
                            fontSize: 17,
                            color: AppColors.dashText,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigate?.call(1),
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: AppColors.dashAccent,
                            fontFamily: AppTheme.fontBold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (recommended.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: 'No recommendations yet',
                    ),
                  )
                else
                  SizedBox(
                    height: hasPrize ? 330 : 300,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recommended.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final e = recommended[i];
                        return SizedBox(
                          width: 260,
                          child: GestureDetector(
                            onTap: () {
                              if (!_registeredIds.contains(e.id)) {
                                _register(e);
                              }
                            },
                            child: EventImageCard(
                              event: e,
                              compact: true,
                              registered: _registeredIds.contains(e.id),
                              saved: savedIds.contains(e.id),
                              onToggleSave: () => ref
                                  .read(savedEventsProvider.notifier)
                                  .toggle(e),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Feed under recommendations
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
                  child: Text(
                    'Happening near you',
                    style: TextStyle(
                      fontFamily: AppTheme.fontBold,
                      fontSize: 17,
                      color: AppColors.dashText,
                    ),
                  ),
                ),
                if (_feed.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: EmptyState(
                      icon: Icons.dynamic_feed_outlined,
                      title: 'No events in your feed yet',
                    ),
                  )
                else
                  ..._feed.take(6).map(
                        (e) => Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: EventImageCard(
                            event: e,
                            registered: _registeredIds.contains(e.id),
                            registering: _busyId == e.id,
                            onRegister: () => _register(e),
                            saved: savedIds.contains(e.id),
                            onToggleSave: () => ref
                                .read(savedEventsProvider.notifier)
                                .toggle(e),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CatTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E293B),
                fontFamily: AppTheme.fontBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
