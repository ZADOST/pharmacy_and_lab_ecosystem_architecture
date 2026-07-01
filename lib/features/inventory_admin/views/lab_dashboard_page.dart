import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';

class LabDashboardPage extends StatefulWidget {
  const LabDashboardPage({Key? key}) : super(key: key);

  @override
  State<LabDashboardPage> createState() => _LabDashboardPageState();
}

class _LabDashboardPageState extends State<LabDashboardPage> {
  List<Map<String, dynamic>> _activeTests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLabTests();
  }

  Future<void> _fetchLabTests() async {
    setState(() => _isLoading = true);
    final tests = await ApiClient.getAllLabTests();
    if (mounted) {
      setState(() {
        _activeTests = tests;
        _isLoading = false;
      });
    }
  }

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

  Future<void> _updateTestStatus(int testId, String newStatus) async {
    // If completing the test, we would normally open a form to input the exact JSON results.
    // For now, we will submit a standard string to finalize the workflow.
    String? mockResultData = newStatus == 'COMPLETED' 
        ? '{"Remarks": {"value": "Analysis Complete", "unit": "", "range": "", "status": "Normal"}}' 
        : null;

    final success = await ApiClient.updateLabStatus(
      testId: testId,
      status: newStatus,
      resultData: mockResultData,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test #$testId successfully updated to $newStatus'),
          backgroundColor: AppColors.primaryTeal,
        ),
      );
      _fetchLabTests(); // Refresh the list to show the new status
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update status.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showCreateTestDialog() {
    final TextEditingController patientIdController = TextEditingController();
    final TextEditingController testNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign New Lab Test'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: patientIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Patient ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: testNameController,
                decoration: const InputDecoration(
                  labelText: 'Test Name (e.g., Blood Panel)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final int? pId = int.tryParse(patientIdController.text.trim());
                final String tName = testNameController.text.trim();

                if (pId != null && tName.isNotEmpty) {
                  Navigator.pop(context); // Close dialog immediately
                  setState(() => _isLoading = true);
                  
                  final success = await ApiClient.createLabTest(patientId: pId, testName: tName);
                  
                  if (success) {
                    _fetchLabTests(); // Refresh UI
                  } else {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to assign test. Verify Patient ID.'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
              child: const Text('Create Test'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratory Operations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLabTests,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTestDialog,
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeTests.isEmpty
              ? const Center(child: Text('No active lab tests.', style: TextStyle(color: Colors.grey, fontSize: 18)))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ListView.builder(
                    itemCount: _activeTests.length,
                    itemBuilder: (context, index) {
                      final test = _activeTests[index];
                      final testId = test['test_id'];
                      final status = test['status'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: status == 'COMPLETED' ? AppColors.successGreen.withOpacity(0.5) : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      test['test_name'],
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Test ID: #$testId | Patient: ${test['patient_name'] ?? 'Unknown'} (ID: ${test['patient_id']})',
                                      style: TextStyle(color: AppColors.textLight),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: _getStatusColor(status)),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Disable dropdown if test is already completed
                                  if (status != 'COMPLETED')
                                    DropdownButton<String>(
                                      icon: const Icon(Icons.edit_note),
                                      underline: const SizedBox(),
                                      items: const [
                                        DropdownMenuItem(value: 'PENDING', child: Text('Mark Pending')),
                                        DropdownMenuItem(value: 'PROCESSING', child: Text('Mark Processing')),
                                        DropdownMenuItem(value: 'COMPLETED', child: Text('Mark Completed')),
                                      ],
                                      onChanged: (String? newValue) {
                                        if (newValue != null && newValue != status) {
                                          _updateTestStatus(testId, newValue);
                                        }
                                      },
                                    )
                                  else
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.check_circle, color: AppColors.successGreen),
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
    );
  }
}