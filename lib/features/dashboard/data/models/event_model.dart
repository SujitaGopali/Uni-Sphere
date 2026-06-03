import 'package:uni_sphere/features/dashboard/domain/entities/event.dart';

class EventModel extends Event {
  EventModel({
    required String id,
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
    required String category,
    required int attendees,
  }) : super(
         id: id,
         title: title,
         description: description,
         dateTime: dateTime,
         location: location,
         category: category,
         attendees: attendees,
       );

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : DateTime.now(),
      location: json['location'] as String? ?? '',
      category: json['category'] as String? ?? '',
      attendees: json['attendees'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'category': category,
      'attendees': attendees,
    };
  }
}
