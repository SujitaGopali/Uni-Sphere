import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/core/api/uni_api_service.dart';
import 'package:uni_sphere/core/models/event_models.dart';
import 'package:uni_sphere/core/widgets/dash_widgets.dart';
import 'package:uni_sphere/core/widgets/event_cover.dart';
import 'package:uni_sphere/core/services/saved_events_provider.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _search = TextEditingController();
  bool _loading = true;
  List<EventModel> _all = [];
  String? _genre;
  String? _type;
  Set<String> _registered = {};
  String? _busyId;
  String? _error;

  static const _genres = [
    'Sports',
    'Technical',
    'Cultural',
    'Workshop',
    'Literary',
    'Management',
    'Other',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
      if (!mounted) return;
      final filtered = filterEventsForUser(events, user?.college);
      setState(() {
        _all = filtered;
        _registered = regs
            .where((r) => r.status != 'cancelled')
            .map((r) => r.event?.id ?? r.eventId ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();
        _loading = false;
        if (filtered.isEmpty && events.isNotEmpty) {
          _error =
              'No events visible for ${user?.college ?? 'your college'} yet.';
        } else if (events.isEmpty) {
          _error = 'Server returned no events.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _all = [];
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<EventModel> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return _all.where((e) {
      if (_genre != null && e.category != _genre) return false;
      if (_type != null && (e.eventType ?? '') != _type) return false;
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q) ||
          (e.college ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _register(EventModel e) async {
    setState(() => _busyId = e.id);
    try {
      await ref.read(uniApiProvider).registerForEvent(e.id, event: e);
      if (!mounted) return;
      setState(() {
        _registered.add(e.id);
        _busyId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered — check QR Passport')),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.mRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover',
                  style: TextStyle(
                    fontFamily: AppTheme.fontBold,
                    fontSize: 22,
                    color: AppColors.dashText,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppColors.dashText),
                  decoration: InputDecoration(
                    hintText: 'Search events…',
                    hintStyle: const TextStyle(color: AppColors.dashMuted),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.dashMuted),
                    filled: true,
                    fillColor: AppColors.surfaceElevatedDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.dashBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.dashBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.dashAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All genres',
                        selected: _genre == null,
                        onTap: () => setState(() => _genre = null),
                      ),
                      ..._genres.map(
                        (g) => _FilterChip(
                          label: g,
                          selected: _genre == g,
                          onTap: () => setState(() => _genre = g),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _FilterChip(
                      label: 'All types',
                      selected: _type == null,
                      onTap: () => setState(() => _type = null),
                    ),
                    _FilterChip(
                      label: 'Intercollegiate',
                      selected: _type == 'Intercollegiate',
                      onTap: () =>
                          setState(() => _type = 'Intercollegiate'),
                    ),
                    _FilterChip(
                      label: 'Intracollegiate',
                      selected: _type == 'Intracollegiate',
                      onTap: () =>
                          setState(() => _type = 'Intracollegiate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const DashLoading()
                : RefreshIndicator(
                    color: AppColors.dashAccent,
                    onRefresh: _load,
                    child: items.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 80),
                              EmptyState(
                                icon: Icons.search_off_rounded,
                                title: _error ?? 'No matching events',
                                subtitle: _error != null
                                    ? 'Pull down to retry'
                                    : null,
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, i) {
                              final e = items[i];
                              final registered = _registered.contains(e.id);
                              final saved = ref
                                  .watch(savedEventsProvider)
                                  .any((s) => s.id == e.id);
                              return EventImageCard(
                                event: e,
                                registered: registered,
                                registering: _busyId == e.id,
                                onRegister: () => _register(e),
                                saved: saved,
                                onToggleSave: () => ref
                                    .read(savedEventsProvider.notifier)
                                    .toggle(e),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.dashAccent : AppColors.dashCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.dashAccent : AppColors.dashBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontBold,
              fontSize: 11,
              color: selected ? Colors.black : AppColors.dashMuted,
            ),
          ),
        ),
      ),
    );
  }
}
