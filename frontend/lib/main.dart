import 'package:calendarapp/homescreen/models/event.dart';
import 'package:calendarapp/homescreen/repository/event_repository.dart';
import 'package:calendarapp/homescreen/screens/homescreen.dart';
import 'package:calendarapp/homescreen/viewmodel/calendar_viewmodel.dart';
import 'package:calendarapp/updatescreen/screens/updatescreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'addscreen/screens/addscreen.dart';
import 'objectbox.g.dart';

late final Store store;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  store = await openStore();
  final eventRepository = EventRepository(store);

  runApp(
      MyApp(
        eventRepository: eventRepository
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.eventRepository
  });

  final EventRepository eventRepository;

  @override
  Widget build(BuildContext context) {

    final lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      brightness: Brightness.light,
    );

    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigoAccent,
          brightness: Brightness.dark
      ),
      scaffoldBackgroundColor: Colors.black,
      brightness: Brightness.dark,
    );

    return ChangeNotifierProvider(
      create: (context) => CalendarViewmodel(eventRepository),
      child:
        MaterialApp(
            title: 'Calendar App',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: "/home",
            routes: {
              "/home": (context) => Homescreen(),
              "/add": (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                if (args is! DateTime) {
                  return const Scaffold(body: Center(child: Text("Error: no selected event!")));
                }
                return AddScreen(date: args);
              },
              "/update": (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                if (args is! Event) {
                  return const Scaffold(body: Center(child: Text("Error: No event found")));
                }
                return UpdateScreen(event: args);
              },
            }
        )
    );
  }
}
