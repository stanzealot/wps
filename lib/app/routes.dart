import 'package:flutter/material.dart';
import 'package:wps/models/permit.dart';
import 'package:wps/screens/auth/login_screen.dart';
import 'package:wps/screens/dashboard/dashboard_screen.dart';
import 'package:wps/screens/admin/admin_dashboard.dart';
import 'package:wps/screens/permits/permits_list_screen.dart';
import 'package:wps/screens/permits/create_permit_screen.dart';
import 'package:wps/screens/permits/approval_queue_screen.dart';
import 'package:wps/screens/permits/permit_detail_screen.dart';
import 'package:wps/screens/profile/profile_screen.dart';

class Routes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String permitsList = '/permits';
  static const String createPermit = '/permits/create';
  static const String approvalQueue = '/approvals';
  static const String permitDetail = '/permits/detail';
  static const String profile = '/profile';
  static const String adminPanel = '/admin';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case Routes.permitsList:
        return MaterialPageRoute(builder: (_) => const PermitsListScreen());
      case Routes.createPermit:
        return MaterialPageRoute(builder: (_) => const CreatePermitScreen());
      case Routes.approvalQueue:
        return MaterialPageRoute(builder: (_) => const ApprovalQueueScreen());
      case Routes.permitDetail:
        if (args is Permit) {
          return MaterialPageRoute(
            builder: (_) => PermitDetailScreen(permit: args),
          );
        }
        return _errorRoute();
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.adminPanel:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Route not found')),
      ),
    );
  }
}
