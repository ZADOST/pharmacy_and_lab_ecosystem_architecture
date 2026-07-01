import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// Since these files are in the exact same folder, we just use their names directly
import 'add_drug_page.dart';
import 'dispense_drug_page.dart';
import 'analytics_page.dart';

// The lab dashboard is in a different feature folder, so it needs the path
import '../../lab_admin/views/lab_dashboard_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _adminScreens = [
    const DispenseDrugPage(),
    const AddDrugPage(),
    const LabDashboardPage(),
    const AnalyticsPage(),
  ];

  void _onMenuTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (MediaQuery.of(context).size.width < 800) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    final Widget sidebar = Drawer(
      elevation: 1,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.primaryTeal),
            accountName: Text('System Administrator', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text('Pharmacy Operations'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: AppColors.primaryTeal, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale, color: AppColors.textDark),
            title: const Text('Dispense / POS'),
            selected: _selectedIndex == 0,
            selectedTileColor: AppColors.backgroundLight,
            onTap: () => _onMenuTapped(0),
          ),
          ListTile(
            leading: const Icon(Icons.add_box, color: AppColors.textDark),
            title: const Text('Add Drug Batch'),
            selected: _selectedIndex == 1,
            selectedTileColor: AppColors.backgroundLight,
            onTap: () => _onMenuTapped(1),
          ),
          ListTile(
            leading: const Icon(Icons.science, color: AppColors.textDark),
            title: const Text('Lab Operations'),
            selected: _selectedIndex == 2,
            selectedTileColor: AppColors.backgroundLight,
            onTap: () => _onMenuTapped(2),
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart, color: AppColors.textDark),
            title: const Text('Sales Analytics'),
            selected: _selectedIndex == 3,
            selectedTileColor: AppColors.backgroundLight,
            onTap: () => _onMenuTapped(3),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );

    return Scaffold(
      appBar: isDesktop ? null : AppBar(title: const Text('Admin Panel')),
      drawer: isDesktop ? null : sidebar,
      body: Row(
        children: [
          if (isDesktop) SizedBox(width: 250, child: sidebar),
          Expanded(
            child: _adminScreens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}