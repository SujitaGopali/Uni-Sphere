import 'package:dio/dio.dart';
import 'package:uni_sphere/core/ai/events_assistant.dart';
import 'package:uni_sphere/core/models/event_models.dart';

/// Optional Gemini enhancement for event Q&A.
class EventsAiService {
  static const _models = [
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
    'gemini-2.0-flash',
  ];

  static Future<String> ask({
    required String question,
    required List<EventModel> events,
    String? college,
    String? userName,
  }) async {
    final assistant = EventsAssistant(
      events: events,
      college: college,
      userName: userName,
    );

    final local = assistant.answerLocal(question);
    final key = EventsAssistant.geminiApiKey;
    if (key.isEmpty) return local;

    try {
      final ai = await _gemini(key, question, events, college);
      if (ai != null && ai.trim().isNotEmpty) return ai.trim();
    } catch (_) {}
    return local;
  }

  static Future<String?> _gemini(
    String apiKey,
    String question,
    List<EventModel> events,
    String? college,
  ) async {
    final catalog = events.take(25).map((e) {
      return '- ${e.title} | ${e.category} | ${e.eventType ?? 'Event'} | '
          '${e.formattedDate} | ${e.location} | college=${e.college ?? '-'}'
          '${e.cashPrize != null ? ' | prize=${e.cashPrize}' : ''}';
    }).join('\n');

    final prompt = '''
You are UniSphere's campus events assistant for a student app in Nepal.
Answer ONLY using the event catalog below. Be concise (max 80 words).
If nothing matches, say so and suggest Discover.
Student college: ${college ?? 'unknown'}

EVENT CATALOG:
$catalog

STUDENT QUESTION:
$question
''';

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 25),
    ));

    for (final model in _models) {
      try {
        final response = await dio.post(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
          queryParameters: {'key': apiKey},
          data: {
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
          },
        );
        final data = response.data;
        if (data is! Map) continue;
        final candidates = data['candidates'];
        if (candidates is! List || candidates.isEmpty) continue;
        final content = candidates.first;
        if (content is! Map) continue;
        final parts = content['content'] is Map
            ? (content['content'] as Map)['parts']
            : null;
        if (parts is! List) continue;
        final text = parts
            .whereType<Map>()
            .map((p) => p['text']?.toString() ?? '')
            .where((t) => t.isNotEmpty)
            .join('')
            .trim();
        if (text.isNotEmpty) return text;
      } catch (_) {
        continue;
      }
    }
    return null;
  }
}
