import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/demo_menu_screen.dart';
import 'screens/home_screen.dart';
import 'screens/journal_entry_screen.dart';
import 'screens/navigation_demo_screen.dart';
import 'utils/constants.dart';

class MochiApp extends StatelessWidget {
  const MochiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mochi',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: GoogleFonts.patrickHandTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'PatrickHand',
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: MochiHomePage.routeName,
      routes: {
        MochiHomePage.routeName: (context) => const MochiHomePage(),
        DemoMenuScreen.routeName: (context) => const DemoMenuScreen(),
        NavigationDemoScreen.routeName: (context) => const NavigationDemoScreen(),
      },
      onGenerateRoute: (settings) {
        final journalRoute = _handleJournalEntryRoute(settings);
        if (journalRoute != null) {
          return journalRoute;
        }
        final navigationRoute = NavigationDemoScreen.onGenerateRoute(settings);
        if (navigationRoute != null) {
          return navigationRoute;
        }
        return MaterialPageRoute<void>(
          builder: (_) => const _RouteErrorScreen(),
          settings: settings,
        );
      },
    );
  }

  Route<dynamic>? _handleJournalEntryRoute(RouteSettings settings) {
    if (settings.name != JournalEntryScreen.routeName) {
      return null;
    }

    final args = settings.arguments;
    if (args is JournalEntryScreenArguments) {
      return MaterialPageRoute<void>(
        builder: (_) => JournalEntryScreen(date: args.date),
        settings: settings,
      );
    }

    return MaterialPageRoute<void>(
      builder: (_) => const _RouteErrorScreen(
        message: 'JournalEntryScreen expects a JournalEntryScreenArguments payload.',
      ),
      settings: settings,
    );
  }
}

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({
    this.message = 'Route was requested with missing or invalid arguments.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
