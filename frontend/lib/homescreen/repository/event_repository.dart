import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../objectbox.g.dart';
import '../models/event.dart';

class EventRepository {
  late final Box<Event> _box;

  static const String baseUrl = "http://172.30.241.30:8081/event";
  static const Duration _timeoutDuration = Duration(seconds: 10);

  EventRepository(Store store) {
    _box = store.box<Event>();
  }

  // List<Event> getEvents() {
  //   return _box.getAll();
  // }

  Future<List<Event>> getEvents() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Event> serverEvents = body.map((dynamic item) => Event.fromJson(item)).toList();

        //if online
        return serverEvents;
      }
    }
    catch (e) {
      debugPrint("Server error or offline: $e");
    }

    //if offline
    return _box.getAll();
  }

  // Event? getEventById(int id) {
  //   return _box.get(id);
  // }

  //TEST
  Future<Event?> getEventById(int id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$id")).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        Event serverEvent = Event.fromJson(jsonDecode(response.body));

        //if online
        return serverEvent;
      }
    }
    catch (e) {
      debugPrint("Server error or offline: $e");
    }

    //if offline
    return _box.get(id);
  }

  // void createEvent(String title, String description, DateTime startDate, DateTime endDate, bool repeating, Color color, bool notifyMe) {
  //   //should return the new EVENT
  //   final newEvent = Event(
  //     title: title,
  //     description: description,
  //     startDate: startDate,
  //     endDate: endDate,
  //     repeating: repeating,
  //     colorValue: color.toARGB32(),
  //     notifyMe: notifyMe
  //   );
  //   _box.put(newEvent);
  // }

  Future<void> createEvent(String title, String description, DateTime startDate, DateTime endDate, bool repeating, Color color, bool notifyMe) async {
    final event = Event(
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      repeating: repeating,
      colorValue: color.toARGB32(),
      notifyMe: notifyMe
    );

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-type": "application/json"},
        body: jsonEncode(event.toJson())
      ).timeout(_timeoutDuration);
      if (response.statusCode == 200) {
        final savedEvent = Event.fromJson(jsonDecode(response.body));
        _box.put(savedEvent);
        return;
      }

    } catch(e) {
      debugPrint("Offline mode: Saving locally only. $e");
    }
    _box.put(event);
  }

  // void updateEvent(int id, String title, String description, DateTime startDate, DateTime endDate, bool repeating, Color color, bool notifyMe) {
  //   //should return the updated EVENT
  //   final updatedEvent = Event.withColor(
  //     id: id,
  //     title: title,
  //     description: description,
  //     startDate: startDate,
  //     endDate: endDate,
  //     repeating: repeating,
  //     color: color,
  //     notifyMe: notifyMe
  //   );
  //   _box.put(updatedEvent);
  // }

  Future<void> updateEvent (int id, String title, String description, DateTime startDate, DateTime endDate, bool repeating, Color color, bool notifyMe) async {
    final updatedEvent = Event.withColor(
      id: id,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      repeating: repeating,
      color: color,
      notifyMe: notifyMe
    );

    try {
      await http.put(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedEvent.toJson()),
      ).timeout(_timeoutDuration);

      _box.put(updatedEvent);
    } catch (e) {
      debugPrint("Offline mode: Update locally. $e");
      _box.put(updatedEvent);
    }
  }

  // void deleteEvent(int id) {
  //   _box.remove(id);
  // }
  void deleteEvent(int id) async {
    try {
      await http.delete(Uri.parse("$baseUrl/$id")).timeout(_timeoutDuration);
      _box.remove(id);
    } catch (e) {
      debugPrint("Offline mode: Delete locally. $e");
      _box.remove(id);
    }
  }

  // List<Event> getSameDay(DateTime date) {
  //   final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0).millisecondsSinceEpoch;
  //   final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
  //
  //   final query = _box.query(
  //       Event_.startDate.lessOrEqual(endOfDay)
  //           .and(Event_.endDate.greaterOrEqual(startOfDay))
  //   ).build();
  //
  //   final results = query.find();
  //   query.close();
  //   return results;
  // }

  Future<List<Event>> getSameDay(DateTime date) async {
    try {
      String dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final response = await http.get(Uri.parse("$baseUrl/same-day?date=$dateStr")).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Event.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Offline mode: Fetching from ObjectBox. $e");
    }

    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;

    final query = _box.query(
        Event_.startDate.lessOrEqual(endOfDay)
            .and(Event_.endDate.greaterOrEqual(startOfDay))
    ).build();

    final results = query.find();
    query.close();
    return results;
  }
}