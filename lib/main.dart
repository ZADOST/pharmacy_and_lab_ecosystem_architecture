import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'routes.dart';

void main() {
  // Ensures Flutter engine is initialized before running the app
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
      // We set the initial route to the Login Page
      initialRoute: AppRoutes.login,
      // We pass our routing logic here
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}