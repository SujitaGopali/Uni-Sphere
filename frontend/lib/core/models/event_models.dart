class EventModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final String location;
  final String category;
  final String? eventType;
  final String? college;
  final int capacity;
  final String? cashPrize;
  final String? brochureImage;
  final String? createdBy;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    this.eventType,
    this.college,
    this.capacity = 0,
    this.cashPrize,
    this.brochureImage,
    this.createdBy,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      eventType: json['eventType']?.toString(),
      college: json['college']?.toString(),
      capacity: _toInt(json['capacity']),
      cashPrize: json['cashPrize']?.toString(),
      brochureImage: json['brochureImage']?.toString(),
      createdBy: json['createdBy']?.toString() ??
          (json['createdBy'] is Map
              ? (json['createdBy'] as Map)['_id']?.toString()
              : null),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'date': date,
        'location': location,
        'category': category,
        if (eventType != null) 'eventType': eventType,
        if (college != null) 'college': college,
        'capacity': capacity,
        if (cashPrize != null) 'cashPrize': cashPrize,
        if (brochureImage != null) 'brochureImage': brochureImage,
        if (createdBy != null) 'createdBy': createdBy,
      };

  Map<String, dynamic> toCreateJson() => {
        'title': title,
        'description': description,
        'date': date,
        'location': location,
        'category': category,
        if (eventType != null) 'eventType': eventType,
        if (college != null) 'college': college,
        'capacity': capacity,
        if (cashPrize != null) 'cashPrize': cashPrize,
        if (brochureImage != null) 'brochureImage': brochureImage,
      };

  String get formattedDate {
    try {
      final d = DateTime.parse(date);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return date;
    }
  }
}

class RegistrationModel {
  final String id;
  final String status;
  final EventModel? event;
  final String? eventId;
  final String? userId;
  final String? createdAt;
  final Map<String, dynamic>? user;

  const RegistrationModel({
    required this.id,
    this.status = 'registered',
    this.event,
    this.eventId,
    this.userId,
    this.createdAt,
    this.user,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    EventModel? event;
    String? eventIdFromRef;
    final rawEvent = json['event'];
    if (rawEvent is Map<String, dynamic>) {
      event = EventModel.fromJson(rawEvent);
    } else if (rawEvent is Map) {
      event = EventModel.fromJson(Map<String, dynamic>.from(rawEvent));
    } else if (rawEvent != null) {
      eventIdFromRef = rawEvent.toString();
    }

    Map<String, dynamic>? user;
    final rawUser = json['user'];
    if (rawUser is Map<String, dynamic>) {
      user = rawUser;
    } else if (rawUser is Map) {
      user = Map<String, dynamic>.from(rawUser);
    }

    return RegistrationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'registered',
      event: event,
      eventId: json['eventId']?.toString() ?? event?.id ?? eventIdFromRef,
      userId: json['userId']?.toString() ??
          (user != null ? user['_id']?.toString() : null),
      createdAt: json['createdAt']?.toString() ?? json['registeredAt']?.toString(),
      user: user,
    );
  }

  RegistrationModel copyWith({
    EventModel? event,
    String? eventId,
    String? status,
  }) {
    return RegistrationModel(
      id: id,
      status: status ?? this.status,
      event: event ?? this.event,
      eventId: eventId ?? this.eventId,
      userId: userId,
      createdAt: createdAt,
      user: user,
    );
  }

  /// Same title the student registered for — never a generic "Event".
  String get eventTitle {
    final t = event?.title.trim();
    if (t != null && t.isNotEmpty) return t;
    return 'Registered event';
  }

  /// Matches website: `UNI-{eventIdLast4}-{registrationIdLast6}`
  String get passCode {
    final eventPart = (event?.id ?? eventId ?? id)
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final e = eventPart.length >= 4
        ? eventPart.substring(eventPart.length - 4).toUpperCase()
        : eventPart.toUpperCase().padLeft(4, '0');
    final r = id.length >= 6
        ? id.substring(id.length - 6).toUpperCase()
        : id.toUpperCase().padLeft(6, '0');
    return 'UNI-$e-$r';
  }

  String qrValue(String userId) =>
      '{"registrationId":"$id","eventId":"${event?.id ?? eventId}","userId":"$userId","type":"event-registration"}';
}

/// Intracollegiate = same college only; Intercollegiate = all.
List<EventModel> filterEventsForUser(
  List<EventModel> events,
  String? userCollege,
) {
  final college = _normalizeCollege(userCollege);
  return events.where((e) {
    final type = (e.eventType ?? '').toLowerCase();
    if (type.contains('inter')) return true;
    if (type.contains('intra')) {
      if (college.isEmpty) return true;
      final eventCollege = _normalizeCollege(e.college);
      if (eventCollege.isEmpty) return true;
      return eventCollege == college ||
          eventCollege.contains(college) ||
          college.contains(eventCollege);
    }
    return true;
  }).toList();
}

String _normalizeCollege(String? value) {
  return (value ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'\([^)]*\)'), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
