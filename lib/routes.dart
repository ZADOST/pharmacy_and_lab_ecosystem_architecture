import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import all the feature views we have built
import 'features/auth/views/login_page.dart';
import 'features/patient_dashboard/views/patient_home_page.dart';
import 'features/inventory_admin/views/add_drug_page.dart';
import 'features/lab_admin/views/lab_dashboard_page.dart';

class AppRoutes {
  // Define string constants for route names to prevent typos
  static const String login = '/';
  static const String patientHome = '/patient-home';
  static const String adminInventory = '/admin-inventory';
  static const String adminLab = '/admin-lab';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case patientHome:
        // When routing to patient home, we expect a patient ID to be passed
        final int patientId = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => PatientHomePage(patientId: patientId),
        );
        
      case adminInventory:
        return MaterialPageRoute(builder: (_) => const AddDrugPage());
        
      case adminLab:
        return MaterialPageRoute(builder: (_) => const LabDashboardPage());
        
      default:
        // Fallback route if something goes wrong
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