import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_sphere/core/api/api_endpoints.dart';
import 'package:uni_sphere/core/models/event_models.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

/// Cover art for event cards — local asset first, then brochure, then stock.
class EventCover extends StatelessWidget {
  final EventModel event;
  final double height;
  final BorderRadius? borderRadius;
  final bool saved;
  final VoidCallback? onToggleSave;

  const EventCover({
    super.key,
    required this.event,
    this.height = 160,
    this.borderRadius,
    this.saved = false,
    this.onToggleSave,
  });

  /// Exact filenames for the 10 seeded events in `assets/images/events/`.
  static const Map<String, String> eventImageFiles = {
    'college fest 2026': 'collegeFest.jpeg',
    'kathmandu hackathon': 'hackathon.jpeg',
    'campus job fair': 'jobfair.jpg',
    'literary meet & open mic': 'literary.jpeg',
    'intercollege sports meet': 'sports.jpeg',
    'startup pitch night': 'management.jpeg',
    'live music night': 'music.jpg',
    'pottery workshop': 'pottery_workshop.jpeg',
    'speak — campus forum': 'speak.jpg',
    'speak - campus forum': 'speak.jpg',
    'talent show': 'talent_show.jpeg',
  };

  static String? fileFor(EventModel event) {
    final title = event.title.toLowerCase().trim();
    return eventImageFiles[title];
  }

  static String slugFor(EventModel event) {
    final file = fileFor(event);
    if (file != null) return file.replaceAll(RegExp(r'\.(jpe?g|png)$'), '');

    final cat = event.category.toLowerCase();
    if (cat.contains('sport')) return 'sports';
    if (cat.contains('cultur') || cat.contains('music') || cat.contains('dance')) {
      return 'collegeFest';
    }
    if (cat.contains('tech')) return 'hackathon';
    if (cat.contains('workshop')) return 'pottery_workshop';
    if (cat.contains('liter')) return 'literary';
    if (cat.contains('manage')) return 'management';
    return 'sports';
  }

  /// Candidate asset paths (first match that exists wins at runtime).
  static List<String> assetCandidates(EventModel event) {
    final exact = fileFor(event);
    if (exact != null) {
      return ['assets/images/events/$exact'];
    }
    final slug = slugFor(event);
    return [
      'assets/images/events/$slug.jpg',
      'assets/images/events/$slug.jpeg',
      'assets/images/events/$slug.png',
    ];
  }

  static String stockUrl(EventModel event) {
    final cat = event.category.toLowerCase();
    if (cat.contains('sport')) {
      return 'https://images.unsplash.com/photo-1461896836934-ffe607ba6851?w=800&q=80';
    }
    if (cat.contains('tech') || cat.contains('workshop')) {
      return 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&q=80';
    }
    if (cat.contains('cultur') || cat.contains('music') || cat.contains('dance')) {
      return 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&q=80';
    }
    if (cat.contains('liter')) {
      return 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&q=80';
    }
    if (cat.contains('manage')) {
      return 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=800&q=80';
    }
    return 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80';
  }

  static IconData categoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('sport')) return Icons.emoji_events_outlined;
    if (cat.contains('tech')) return Icons.laptop_mac_outlined;
    if (cat.contains('workshop')) return Icons.school_outlined;
    if (cat.contains('cultur')) return Icons.palette_outlined;
    if (cat.contains('liter')) return Icons.menu_book_outlined;
    if (cat.contains('manage')) return Icons.business_center_outlined;
    return Icons.grid_view_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _EventCoverImage(event: event),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            if (onToggleSave != null)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onToggleSave,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: saved ? const Color(0xFFFF6B6B) : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventCoverImage extends StatefulWidget {
  final EventModel event;

  const _EventCoverImage({required this.event});

  @override
  State<_EventCoverImage> createState() => _EventCoverImageState();
}

class _EventCoverImageState extends State<_EventCoverImage> {
  String? _localPath;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _resolveLocal();
  }

  @override
  void didUpdateWidget(covariant _EventCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.id != widget.event.id ||
        oldWidget.event.title != widget.event.title) {
      _resolved = false;
      _localPath = null;
      _resolveLocal();
    }
  }

  Future<void> _resolveLocal() async {
    for (final path in EventCover.assetCandidates(widget.event)) {
      try {
        await rootBundle.load(path);
        if (!mounted) return;
        setState(() {
          _localPath = path;
          _resolved = true;
        });
        return;
      } catch (_) {
        // try next extension
      }
    }
    if (!mounted) return;
    setState(() {
      _localPath = null;
      _resolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolved) {
      return _Fallback(event: widget.event);
    }

    final brochure = ApiEndpoints.resolveMediaUrl(widget.event.brochureImage);
    final stock = EventCover.stockUrl(widget.event);

    if (_localPath != null) {
      return Image.asset(
        _localPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _networkOrFallback(brochure, stock),
      );
    }

    return _networkOrFallback(brochure, stock);
  }

  Widget _networkOrFallback(String brochure, String stock) {
    final url = brochure.isNotEmpty ? brochure : stock;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        if (brochure.isNotEmpty) {
          return Image.network(
            stock,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _Fallback(event: widget.event),
          );
        }
        return _Fallback(event: widget.event);
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _Fallback(event: widget.event);
      },
    );
  }
}

class _Fallback extends StatelessWidget {
  final EventModel event;

  const _Fallback({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.dashAccentSoft,
      child: Center(
        child: Icon(
          EventCover.categoryIcon(event.category),
          size: 42,
          color: AppColors.dashAccentText,
        ),
      ),
    );
  }
}

class EventImageCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onRegister;
  final bool registered;
  final bool registering;
  final bool compact;
  final bool saved;
  final VoidCallback? onToggleSave;

  const EventImageCard({
    super.key,
    required this.event,
    this.onRegister,
    this.registered = false,
    this.registering = false,
    this.compact = false,
    this.saved = false,
    this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final meta =
        '${event.formattedDate}  ·  ${event.location.isEmpty ? (event.college ?? 'Campus') : event.location}';
    final prize = (event.cashPrize ?? '').trim();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.dashCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dashBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventCover(
            event: event,
            height: compact ? 120 : 168,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            saved: saved,
            onToggleSave: onToggleSave,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, compact ? 10 : 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SoftChipLite(label: event.category),
                    const SizedBox(width: 6),
                    if (event.eventType != null)
                      SoftChipLite(
                        label: event.eventType!,
                        muted: true,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontBold,
                    fontSize: compact ? 14 : 16,
                    color: AppColors.dashText,
                    height: 1.25,
                  ),
                ),
                if (event.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.description.trim(),
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      color: AppColors.dashMuted,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.dashMuted,
                  ),
                ),
                if (prize.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SoftChipLite(label: 'Prize: $prize'),
                ],
                if (!compact && onRegister != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: registered
                        ? const SoftChipLite(label: 'Registered')
                        : SizedBox(
                            height: 36,
                            child: FilledButton(
                              onPressed: registering ? null : onRegister,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.dashAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: registering
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontBold,
                                        fontSize: 13,
                                      ),
                                    ),
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SoftChipLite extends StatelessWidget {
  final String label;
  final bool muted;

  const SoftChipLite({super.key, required this.label, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: muted ? AppColors.surfaceElevatedDark : AppColors.dashAccentSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: muted
              ? AppColors.dashBorder
              : AppColors.dashAccent.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: AppTheme.fontBold,
          fontSize: 10,
          color: muted ? AppColors.dashMuted : AppColors.dashAccentText,
        ),
      ),
    );
  }
}
