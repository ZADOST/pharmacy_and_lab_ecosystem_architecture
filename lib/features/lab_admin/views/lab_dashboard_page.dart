import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/lab_test_model.dart';

class LabDashboardPage extends StatefulWidget {
  const LabDashboardPage({Key? key}) : super(key: key);

  @override
  State<LabDashboardPage> createState() => _LabDashboardPageState();
}

class _LabDashboardPageState extends State<LabDashboardPage> {
  // Mock data representing what would be fetched from ApiClient.getLabTests()
  List<LabTestModel> _activeTests = [
    LabTestModel(testId: 101, patientId: 5, testName: 'Complete Blood Count (CBC)', status: 'PENDING'),
    LabTestModel(testId: 102, patientId: 12, testName: 'Lipid Panel', status: 'PROCESSING'),
    LabTestModel(testId: 103, patientId: 8, testName: 'Liver Function Test', status: 'COMPLETED', resultData: 'Normal'),
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orangeAccent;
      case 'PROCESSING':
        return Colors.blueAccent;
      case 'COMPLETED':
        return AppColors.successGreen;
      default:
        return AppColors.textLight;
    }
  }

  Future<void> _updateTestStatus(int index, String newStatus) async {
    // In a production environment, you would call your API here:
    // await ApiClient.updateLabStatus(_activeTests[index].testId, newStatus);
    
    setState(() {
      _activeTests[index] = LabTestModel(
        testId: _activeTests[index].testId,
        patientId: _activeTests[index].patientId,
        testName: _activeTests[index].testName,
        status: newStatus,
        resultData: _activeTests[index].resultData,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Test #${_activeTests[index].testId} updated to $newStatus'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratory Operations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Patient Tests',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _activeTests.length,
                itemBuilder: (context, index) {
                  final test = _activeTests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.testName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Test ID: #${test.testId} | Patient ID: ${test.patientId}',
                                style: TextStyle(
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(test.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(test.status),
                                  ),
                                ),
                                child: Text(
                                  test.status,
                                  style: TextStyle(
                                    color: _getStatusColor(test.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Status Update Dropdown
                              DropdownButton<String>(
                                icon: const Icon(Icons.edit_note),
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(value: 'PENDING', child: Text('Mark Pending')),
                                  DropdownMenuItem(value: 'PROCESSING', child: Text('Mark Processing')),
                                  DropdownMenuItem(value: 'COMPLETED', child: Text('Mark Completed')),
                                ],
                                onChanged: (String? newValue) {
                                  if (newValue != null && newValue != test.status) {
                                    _updateTestStatus(index, newValue);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}