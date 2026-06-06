  import 'dart:ui';
  
  import 'package:objectbox/objectbox.dart';
  
  @Entity()
  class Event {
    @Id(assignable: true)
    int id = 0;
  
    String title;
    String description;
  
    @Property(type: PropertyType.date)
    DateTime startDate;
    @Property(type: PropertyType.date)
    DateTime endDate;
  
    bool repeating;
    int colorValue;
    bool notifyMe;
  
    Event({
      this.id = 0,
      required this.title,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.repeating,
      required this.colorValue,
      required this.notifyMe,
    });
  
    Color get color => Color(colorValue);
    set color(Color newColor) {
      colorValue = newColor.toARGB32();
    }
  
    factory Event.withColor({
      int id = 0,
      required String title,
      required String description,
      required DateTime startDate,
      required DateTime endDate,
      required bool repeating,
      required bool notifyMe,
      required Color color,
    }) {
      return Event(
        id: id,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        repeating: repeating,
        notifyMe: notifyMe,
        colorValue: color.toARGB32(),
      );
    }

    factory Event.fromJson(Map<String, dynamic> json) {
      return Event(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        repeating: json['repeating'] ?? false,
        colorValue: json['colorValue'] ?? 0xFF000000,
        notifyMe: json['notifyMe'] ?? false,
      );
    }

    Map<String, dynamic> toJson() {
      return {
        if (id != 0) 'id': id,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'repeating': repeating,
        'colorValue': colorValue,
        'notifyMe': notifyMe,
      };
    }
  }