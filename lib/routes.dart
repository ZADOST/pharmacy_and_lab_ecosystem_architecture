import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'features/auth/views/admin_login_page.dart';
import 'features/auth/views/login_page.dart';
import 'features/patient_dashboard/views/patient_home_page.dart';
import 'features/inventory_admin/views/admin_dashboard_page.dart'; // <-- IMPORT THIS

class AppRoutes {
  static const String login = '/';
  static const String patientHome = '/patient-home';
  static const String adminDashboard = '/admin-dashboard'; // <-- CHANGED ROUTE NAME
  static const String adminLogin = '/admin-login';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case patientHome:
        final int patientId = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => PatientHomePage(patientId: patientId),
        );
        case adminLogin:
  return MaterialPageRoute(builder: (_) => const AdminLoginPage());
  
      case adminDashboard: // <-- NOW POINTS HERE
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}