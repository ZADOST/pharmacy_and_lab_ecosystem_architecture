import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../core/theme/app_colors.dart';

class PatientHomePage extends StatefulWidget {
  final int patientId;

  const PatientHomePage({Key? key, required this.patientId}) : super(key: key);

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mocking the data structure that would be returned from get_patient_history.php
  // We use standard professional medical parameters for the mock data.
  final List<Map<String, dynamic>> _labResults = [
    {
      "test_name": "Complete Blood Count (CBC)",
      "status": "COMPLETED",
      "completed_at": "2026-07-01",
      "result_data": jsonEncode({
        "Hemoglobin": {"value": 14.2, "unit": "g/dL", "range": "13.8 - 17.2", "status": "Normal"},
        "WBC": {"value": 6.5, "unit": "x10^9/L", "range": "4.5 - 11.0", "status": "Normal"},
        "Platelets": {"value": 210, "unit": "x10^9/L", "range": "150 - 450", "status": "Normal"},
      })
    },
    {
      "test_name": "Comprehensive Metabolic Panel",
      "status": "PROCESSING",
      "completed_at": null,
      "result_data": null
    }
  ];

  final List<Map<String, dynamic>> _medications = [
    {
      "brand_name": "Panadol Advance 500mg",
      "quantity": 2,
      "sale_date": "2026-06-28",
      "description": "Take 2 tablets every 6 hours as needed for pain."
    },
    {
      "brand_name": "Amoxicillin 250mg",
      "quantity": 1,
      "sale_date": "2026-05-15",
      "description": "Complete the full 7-day course. Take with food."
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLabDetailsModal(BuildContext context, Map<String, dynamic> test) {
    if (test['status'] != 'COMPLETED' || test['result_data'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Results are not yet available for this test.')),
      );
      return;
    }

    final Map<String, dynamic> metrics = jsonDecode(test['result_data']);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                test['test_name'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Completed: ${test['completed_at']}',
                style: TextStyle(color: AppColors.textLight),
              ),
              const Divider(height: 30, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Parameter', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Ref. Range', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
                ],
              ),
              const SizedBox(height: 10),
              ...metrics.entries.map((entry) {
                final data = entry.value as Map<String, dynamic>;
                final isNormal = data['status'] == 'Normal';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: Text(entry.key)),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${data['value']} ${data['unit']}',
                          style: TextStyle(
                            color: isNormal ? AppColors.textDark : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          data['range'],
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppColors.textLight, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                  child: const Text('Close Report'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Health Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryTeal,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primaryTeal,
          tabs: const [
            Tab(icon: Icon(Icons.science), text: 'Lab Results'),
            Tab(icon: Icon(Icons.medication), text: 'Medications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Lab Results
          ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _labResults.length,
            itemBuilder: (context, index) {
              final test = _labResults[index];
              final isCompleted = test['status'] == 'COMPLETED';
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    backgroundColor: isCompleted ? AppColors.successGreen.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.hourglass_bottom,
                      color: isCompleted ? AppColors.successGreen : Colors.orange,
                    ),
                  ),
                  title: Text(test['test_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    isCompleted ? 'Ready to view' : 'Currently being processed in the lab',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                  trailing: isCompleted
                      ? const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryTeal)
                      : null,
                  onTap: () => _showLabDetailsModal(context, test),
                ),
              );
            },
          ),

          // TAB 2: Medications
          ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _medications.length,
            itemBuilder: (context, index) {
              final med = _medications[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            med['brand_name'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          Text(
                            'Qty: ${med['quantity']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Purchased: ${med['sale_date']}',
                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                      const Divider(),
                      Text(
                        med['description'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}