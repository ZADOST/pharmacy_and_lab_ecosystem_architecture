import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/theme/app_colors.dart';

void main() {
  runApp(const PharmacyLabSystem());
}

class PharmacyLabSystem extends StatelessWidget {
  const PharmacyLabSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmaLab',
      theme: AppColors.clinicalTheme,
      debugShowCheckedModeBanner: false,
      home: const RoleRouter(),
    );
  }
}

class RoleRouter extends StatefulWidget {
  const RoleRouter({super.key});

  @override
  State<RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  // In a real app, this value comes from your AuthController/SharedPrefs
  final String currentUserRole = 'ADMIN'; 

  @override
  Widget build(BuildContext context) {
    // If the user is an admin, and they are on the Web, show the Web Dashboard
    if (currentUserRole == 'ADMIN' && kIsWeb) {
      return const AdminWebDashboard();
    } 
    // If the user is a patient, show the Mobile UI
    else if (currentUserRole == 'PATIENT') {
      return const PatientMobileDashboard();
    } 
    // Fallback login screen
    else {
      return const LoginScreen();
    }
  }
}

// ---------------------------------------------------------
// Placeholder UI components to demonstrate routing
// ---------------------------------------------------------

class AdminWebDashboard extends StatelessWidget {
  const AdminWebDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pharmacy & Lab Admin Panel')),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.white,
            child: ListView(
              children: const [
                ListTile(leading: Icon(Icons.inventory), title: Text('Inventory')),
                ListTile(leading: Icon(Icons.science), title: Text('Laboratory')),
                ListTile(leading: Icon(Icons.analytics), title: Text('Sales Analytics')),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Center(
              child: Text(
                'Desktop Inventory Management View',
                style: TextStyle(color: AppColors.textDark, fontSize: 24),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PatientMobileDashboard extends StatelessWidget {
  const PatientMobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Health Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Colors.white,
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.science, color: AppColors.primaryTeal),
              title: const Text('Recent Lab Test: Blood Panel'),
              subtitle: const Text('Status: COMPLETED'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to test details
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.medication, color: AppColors.primaryTeal),
              title: const Text('Purchase History'),
              subtitle: const Text('View your previously prescribed medications'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('Login with Facebook / Email'),
        ),
      ),
    );
  }
}