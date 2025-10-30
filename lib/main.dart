import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/demo_menu_screen.dart';
import 'screens/mochi_home_page.dart';
import 'screens/navigation_demo_screen.dart';
import 'screens/rest_workflow/rest_workflow_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MochiApp()));
}

class MochiApp extends StatelessWidget {
  const MochiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mochi',
      theme: AppTheme.lightTheme(),
      initialRoute: MochiHomePage.routeName,
      routes: {
        MochiHomePage.routeName: (context) => const MochiHomePage(),
        DemoMenuScreen.routeName: (context) => const DemoMenuScreen(),
        NavigationDemoScreen.routeName: (context) => const NavigationDemoScreen(),
        RestWorkflowScreen.routeName: (context) => const RestWorkflowScreen(),
      },
      onGenerateRoute: NavigationDemoScreen.onGenerateRoute,
    );
  }
}
