import 'package:calendarapp/homescreen/utils/date_utils.dart';
import 'package:flutter/cupertino.dart';

import '../models/event.dart';
import '../repository/event_repository.dart';

class CalendarViewmodel extends ChangeNotifier {
  final EventRepository _eventRepository;
  late List<Event> _allEvents = [];
  DateTime _currentDate = DateTime.now();
  DateTime get currentDate => _currentDate;
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, List<Color>> dateToColorMap = {};
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Event> _selectedDayEvents = [];
  List<Event> getEventsForSelected() {
    return _selectedDayEvents;
  }

  CalendarViewmodel(this._eventRepository) {
    _refreshEvents();
  }

  Future<void> _refreshEvents() async {
    _isLoading = true;
    // ... existing refresh logic ...
    _allEvents = await _eventRepository.getEvents();
    // ... map generation ...
    _selectedDayEvents = await _eventRepository.getSameDay(_selectedDate);

    _isLoading = false;
    notifyListeners();
  }

  void generateDateToColorMap() {
    for (int i=0; i<_allEvents.length; i++)
    {
      Event e = _allEvents[i];
      DateTime d = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
      DateTime end = DateTime(e.endDate.year, e.endDate.month, e.endDate.day, 23, 59, 59);
      while (d.isBefore(end)) {
        dateToColorMap.putIfAbsent(d, () => []).add(e.color);
        d = d.add(const Duration(days: 1));
      }
    }
  }

  Future<void> dateSelected(DateTime date) async {
    _selectedDate = date;

    // Start loading
    _isLoading = true;
    notifyListeners(); // This tells the UI to show the spinner

    // Fetch data (await the future)
    _selectedDayEvents = await _eventRepository.getSameDay(date);

    // Stop loading
    _isLoading = false;
    notifyListeners(); // This tells the UI to show the list
  }

  List<List<CalendarDay>> get daysInMonth {
    return generateDaysForMonth(_currentDate);
  }
  String get monthYearString {
    return "${getMonthByIndex(_currentDate.month)} ${_currentDate.year}";
  }

  void goToNextMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    notifyListeners();
  }

  void goToPreviousMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    notifyListeners();
  }

  void setCurrentDate(DateTime date) {
    _currentDate = date;
    notifyListeners();
  }

  void goToToday() {
    _currentDate = DateTime.now();
    notifyListeners();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color? getColorForDay(DateTime date) {
    final auxDate = DateTime(date.year, date.month, date.day);
    if (dateToColorMap.containsKey(auxDate)) {
      return dateToColorMap[date]?.first;
    }
    return null;
  }

  Future<void> addEvent(String title, String description, DateTime startDate, DateTime endDate, bool repeating, Color color, bool notifyMe) async {
    await _eventRepository.createEvent(title, description, startDate, endDate, repeating, color, notifyMe);
    _refreshEvents();
    notifyListeners();
  }

  Future<void> updateEvent(int id, String title, String description, DateTime startDate, DateTime endDate, bool repeating, Color color, bool notifyMe) async {
    _eventRepository.updateEvent(id, title, description, startDate, endDate, repeating, color, notifyMe);
    _refreshEvents();
    notifyListeners();
  }

  Future<void> deleteEvent(int id) async {
    _eventRepository.deleteEvent(id);
    _refreshEvents();
    notifyListeners();
  }
}