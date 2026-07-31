import 'package:uni_sphere/core/models/event_models.dart';

/// Answers student questions about campus events using live event data.
/// Works offline from API payloads; optionally enhances via Gemini when
/// `--dart-define=GEMINI_API_KEY=...` is set.
class EventsAssistant {
  EventsAssistant({
    required this.events,
    this.college,
    this.userName,
  });

  final List<EventModel> events;
  final String? college;
  final String? userName;

  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  Future<String> answer(String rawQuestion) async {
    return answerLocal(rawQuestion);
  }

  /// Synchronous local Q&A used by [EventsAiService] and as Gemini fallback.
  String answerLocal(String rawQuestion) {
    final q = rawQuestion.trim();
    if (q.isEmpty) {
      return 'Ask me anything about campus events — for example, “Any events tomorrow?”';
    }
    return _answerLocally(q);
  }

  String _answerLocally(String question) {
    final q = question.toLowerCase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_matches(q, ['hello', 'hi', 'hey', 'namaste'])) {
      final name = (userName ?? 'there').split(' ').first;
      return 'Hey $name! I can help with UniSphere events — try “events tomorrow”, “sports this week”, or “intercollege events”.';
    }

    if (_matches(q, ['help', 'what can you', 'how do you'])) {
      return 'I answer questions about events you can see in UniSphere: dates, categories (Sports, Cultural, Technical…), inter/intra college, venues, and prizes. Ask naturally — e.g. “Is there a hackathon soon?”';
    }

    if (_matches(q, ['how many', 'count', 'total events'])) {
      return events.isEmpty
          ? 'I don’t see any events for your college right now.'
          : 'You currently have ${events.length} event${events.length == 1 ? '' : 's'} available.';
    }

    DateTime? start;
    DateTime? end;
    String rangeLabel = 'upcoming';

    if (_matches(q, ['tomorrow'])) {
      start = today.add(const Duration(days: 1));
      end = start.add(const Duration(days: 1));
      rangeLabel = 'tomorrow';
    } else if (_matches(q, ['today', 'tonight'])) {
      start = today;
      end = today.add(const Duration(days: 1));
      rangeLabel = 'today';
    } else if (_matches(q, ['this weekend', 'weekend'])) {
      final weekday = now.weekday; // Mon=1 … Sun=7
      final saturday = today.add(Duration(days: (6 - weekday + 7) % 7));
      start = saturday;
      end = saturday.add(const Duration(days: 2));
      rangeLabel = 'this weekend';
    } else if (_matches(q, ['this week', 'week'])) {
      start = today;
      end = today.add(const Duration(days: 7));
      rangeLabel = 'this week';
    } else if (_matches(q, ['next week'])) {
      start = today.add(const Duration(days: 7));
      end = start.add(const Duration(days: 7));
      rangeLabel = 'next week';
    } else if (_matches(q, ['month', 'this month'])) {
      start = today;
      end = DateTime(now.year, now.month + 1, now.day);
      rangeLabel = 'this month';
    }

    String? category;
    if (_matches(q, ['sport', 'football', 'basketball', 'athlet'])) {
      category = 'Sports';
    } else if (_matches(q, ['cultural', 'dance', 'music', 'fest', 'culture'])) {
      category = 'Cultural';
    } else if (_matches(q, ['tech', 'hackathon', 'coding', 'technical', 'workshop'])) {
      if (_matches(q, ['workshop'])) {
        category = 'Workshop';
      } else {
        category = 'Technical';
      }
    } else if (_matches(q, ['literary', 'poetry', 'writing'])) {
      category = 'Literary';
    } else if (_matches(q, ['management', 'startup', 'pitch', 'business'])) {
      category = 'Management';
    }

    String? type;
    if (_matches(q, ['intercollege', 'inter-college', 'inter collegiate', 'intercollegiate'])) {
      type = 'Intercollegiate';
    } else if (_matches(q, ['intracollege', 'intra-college', 'campus only', 'intracollegiate'])) {
      type = 'Intracollegiate';
    }

    var filtered = List<EventModel>.from(events);
    if (start != null && end != null) {
      filtered = filtered.where((e) {
        final d = _parseDate(e.date);
        if (d == null) return false;
        final day = DateTime(d.year, d.month, d.day);
        return !day.isBefore(start!) && day.isBefore(end!);
      }).toList();
    } else {
      // Default: upcoming only
      filtered = filtered.where((e) {
        final d = _parseDate(e.date);
        if (d == null) return true;
        return !d.isBefore(today.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (category != null) {
      filtered = filtered
          .where((e) => e.category.toLowerCase().contains(category!.toLowerCase()))
          .toList();
    }
    if (type != null) {
      filtered = filtered
          .where((e) => (e.eventType ?? '').toLowerCase().contains(type!.toLowerCase().substring(0, 5)))
          .toList();
    }

    // Keyword search for leftover tokens (titles)
    final keywords = q
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .where((w) => !_stopwords.contains(w))
        .toList();
    if (keywords.isNotEmpty &&
        start == null &&
        category == null &&
        type == null &&
        !_matches(q, ['event', 'events', 'any', 'what', 'when', 'where', 'list', 'show'])) {
      final hit = events.where((e) {
        final hay =
            '${e.title} ${e.description} ${e.category} ${e.location} ${e.college ?? ''}'
                .toLowerCase();
        return keywords.any(hay.contains);
      }).toList();
      if (hit.isNotEmpty) filtered = hit;
    }

    filtered.sort((a, b) {
      final da = _parseDate(a.date) ?? DateTime(2100);
      final db = _parseDate(b.date) ?? DateTime(2100);
      return da.compareTo(db);
    });

    if (_matches(q, ['prize', 'cash', 'reward', 'trophy'])) {
      final withPrize = filtered.where((e) => (e.cashPrize ?? '').isNotEmpty).toList();
      if (withPrize.isEmpty) {
        return 'None of the visible events list a cash prize right now.';
      }
      return _formatList(
        'Events with prizes:',
        withPrize.take(5).toList(),
        extra: (e) => e.cashPrize,
      );
    }

    if (_matches(q, ['where', 'location', 'venue'])) {
      if (filtered.isEmpty) {
        return 'I couldn’t find matching events to show venues for.';
      }
      final e = filtered.first;
      return '${e.title} is at ${e.location.isEmpty ? (e.college ?? 'campus') : e.location} on ${e.formattedDate}.';
    }

    if (_matches(q, ['passport', 'qr', 'pass', 'check-in', 'check in'])) {
      return 'After you register, open Passport in the bottom nav to show your QR pass at the gate.';
    }

    if (_matches(q, ['register', 'how to join', 'sign up for'])) {
      return 'Open Discover (or Home feed), pick an event, tap Register — your pass then appears in Passport.';
    }

    if (filtered.isEmpty) {
      final bits = <String>[];
      if (rangeLabel != 'upcoming') bits.add(rangeLabel);
      if (category != null) bits.add(category.toLowerCase());
      if (type != null) bits.add(type.toLowerCase());
      final scope = bits.isEmpty ? 'that match' : bits.join(' · ');
      return 'No events $scope right now. Try Discover, or ask “what’s on this week?”';
    }

    final header = rangeLabel == 'upcoming' && category == null && type == null
        ? 'Here’s what’s coming up:'
        : 'Events${rangeLabel != 'upcoming' ? ' $rangeLabel' : ''}${category != null ? ' · $category' : ''}${type != null ? ' · $type' : ''}:';

    return _formatList(header, filtered.take(6).toList());
  }

  String _formatList(
    String header,
    List<EventModel> items, {
    String? Function(EventModel)? extra,
  }) {
    final buf = StringBuffer(header);
    for (final e in items) {
      final type = e.eventType != null ? ' · ${e.eventType}' : '';
      final more = extra?.call(e);
      buf.writeln();
      buf.write('• ${e.title} — ${e.formattedDate}$type');
      if (e.location.isNotEmpty) buf.write(' @ ${e.location}');
      if (more != null && more.isNotEmpty) buf.write(' ($more)');
    }
    if (items.length >= 6) {
      buf.writeln();
      buf.write('…and more in Discover.');
    }
    return buf.toString().trim();
  }

  static DateTime? _parseDate(String raw) {
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }

  static bool _matches(String q, List<String> keys) =>
      keys.any((k) => q.contains(k));

  static const _stopwords = {
    'what',
    'when',
    'where',
    'which',
    'there',
    'about',
    'events',
    'event',
    'please',
    'could',
    'would',
    'should',
    'have',
    'with',
    'from',
    'this',
    'that',
    'they',
    'them',
    'your',
    'mine',
    'campus',
    'college',
    'unisphere',
    'tomorrow',
    'today',
    'week',
    'month',
    'weekend',
    'any',
    'some',
    'tell',
    'show',
    'list',
    'find',
    'are',
    'is',
    'the',
    'and',
    'for',
  };
}
