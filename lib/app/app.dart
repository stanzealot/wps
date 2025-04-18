import 'package:flutter/material.dart';
import 'package:wps/screens/auth/login_screen.dart';
import 'package:wps/screens/dashboard/dashboard_screen.dart';
import 'routes.dart';
import 'theme.dart';

class PermitToWorkApp extends StatelessWidget {
  const PermitToWorkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permit to Work System',
      theme: appTheme,
      initialRoute: Routes.login,
      onGenerateRoute: RouteGenerator.generateRoute,
      home: const LoginScreen(), // Fallback in case routing fails
    );
  }
}
