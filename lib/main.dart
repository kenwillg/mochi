import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mochi/views/rest_workflow/rest_workflow_view.dart';
import 'package:mochi/views/screens/demo_menu_view.dart';
import 'package:mochi/views/screens/mochi_home_view.dart';
import 'package:mochi/views/screens/navigation_demo_view.dart';
import 'package:mochi/views/theme/app_theme.dart';

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
      initialRoute: MochiHomeView.routeName,
      routes: {
        MochiHomeView.routeName: (context) => const MochiHomeView(),
        DemoMenuView.routeName: (context) => const DemoMenuView(),
        NavigationDemoView.routeName: (context) => const NavigationDemoView(),
        RestWorkflowView.routeName: (context) => const RestWorkflowView(),
      },
      onGenerateRoute: NavigationDemoView.onGenerateRoute,
    );
  }
}
