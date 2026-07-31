import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_sphere/core/ai/events_ai_service.dart';
import 'package:uni_sphere/core/api/uni_api_service.dart';
import 'package:uni_sphere/core/models/event_models.dart';
import 'package:uni_sphere/core/widgets/dash_widgets.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:uni_sphere/themes/app_colors.dart';
import 'package:uni_sphere/themes/app_theme.dart';

class EventsAiChatScreen extends ConsumerStatefulWidget {
  const EventsAiChatScreen({super.key});

  @override
  ConsumerState<EventsAiChatScreen> createState() => _EventsAiChatScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class _EventsAiChatScreenState extends ConsumerState<EventsAiChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_ChatMessage>[
    _ChatMessage(
      text:
          'Hi! I’m your UniSphere events assistant. Ask me things like “Any events tomorrow?” or “Sports this week”.',
      isUser: false,
    ),
  ];
  List<EventModel> _events = [];
  bool _loadingEvents = true;
  bool _thinking = false;

  static const _suggestions = [
    'Any events tomorrow?',
    'What’s on this week?',
    'Intercollege events',
    'Sports events',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _loadingEvents = true);
    try {
      final user = ref.read(authViewModelProvider).user;
      final events = await ref.read(uniApiProvider).getEvents();
      if (!mounted) return;
      setState(() {
        _events = filterEventsForUser(events, user?.college);
        _loadingEvents = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _events = [];
        _loadingEvents = false;
      });
    }
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _thinking) return;
    _input.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _thinking = true;
    });
    _scrollToEnd();

    final user = ref.read(authViewModelProvider).user;
    final reply = await EventsAiService.ask(
      question: text,
      events: _events,
      college: user?.college,
      userName: user?.firstName,
    );

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(text: reply, isUser: false));
      _thinking = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dashboard,
      child: Scaffold(
        backgroundColor: AppColors.dashBg,
        appBar: AppBar(
          backgroundColor: AppColors.dashBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.dashText),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Events AI',
                style: TextStyle(
                  fontFamily: AppTheme.fontBold,
                  fontSize: 16,
                  color: AppColors.dashText,
                ),
              ),
              Text(
                'Ask about campus events',
                style: TextStyle(fontSize: 11, color: AppColors.dashMuted),
              ),
            ],
          ),
          actions: [
            if (_loadingEvents)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.dashAccent,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SoftChip(label: '${_events.length} events'),
              ),
          ],
        ),
        body: DashboardBackground(
          child: Column(
            children: [
              if (_messages.length <= 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestions
                        .map(
                          (s) => ActionChip(
                            label: Text(
                              s,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: AppColors.dashCard,
                            side: const BorderSide(color: AppColors.dashBorder),
                            labelStyle:
                                const TextStyle(color: AppColors.dashAccentText),
                            onPressed: _thinking ? null : () => _send(s),
                          ),
                        )
                        .toList(),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: _messages.length + (_thinking ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (_thinking && i == _messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: SoftChip(label: 'Thinking…'),
                        ),
                      );
                    }
                    final m = _messages[i];
                    return Align(
                      alignment: m.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.82,
                        ),
                        decoration: BoxDecoration(
                          color: m.isUser
                              ? AppColors.dashAccent
                              : AppColors.dashCard,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(m.isUser ? 16 : 4),
                            bottomRight: Radius.circular(m.isUser ? 4 : 16),
                          ),
                          border: m.isUser
                              ? null
                              : Border.all(color: AppColors.dashBorder),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            color: m.isUser ? Colors.black : AppColors.dashText,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          enabled: !_thinking,
                          style: const TextStyle(color: AppColors.dashText),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'Ask about events…',
                            hintStyle:
                                const TextStyle(color: AppColors.dashMuted),
                            filled: true,
                            fillColor: AppColors.surfaceElevatedDark,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.dashBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.dashBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.dashAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: AppColors.dashAccent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: _thinking ? null : () => _send(),
                          borderRadius: BorderRadius.circular(14),
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(Icons.send_rounded, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
