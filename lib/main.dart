import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'routes.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/patient_dashboard/views/patient_home_page.dart';
import 'features/inventory_admin/views/admin_dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PharmacyLabSystem());
}

class PharmacyLabSystem extends StatelessWidget {
  const PharmacyLabSystem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmaLab Ecosystem',
      theme: AppColors.clinicalTheme,
      debugShowCheckedModeBanner: false,
      // Instead of defaulting to the login route, we use a FutureBuilder to check the vault
      home: FutureBuilder<Map<String, String?>>(
        future: AuthController.checkExistingSession(),
        builder: (context, snapshot) {
          // While checking the device storage, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.backgroundLight,
              body: Center(child: CircularProgressIndicator(color: AppColors.primaryTeal)),
            );
          }

          final sessionData = snapshot.data;
          
          // If a session exists and the role is a Patient, route them directly to their dashboard
          if (sessionData != null && sessionData['role'] == 'PATIENT' && sessionData['patient_id'] != null) {
            final int pId = int.parse(sessionData['patient_id']!);
            return PatientHomePage(patientId: pId);
          }
          
          // If a session exists and the role is Admin, route to the Admin Dashboard
          if (sessionData != null && sessionData['role'] == 'ADMIN') {
            return const AdminDashboardPage();
          }

          // If no session is found, fall back to the AppRoutes logic which defaults to the Login Page
          return Navigator(
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: AppRoutes.login,
          );
        },
      ),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}