import 'dart:convert';

class PatientLabModel {
  final int testId;
  final String testName;
  final String status;
  final String? completedAt;
  final Map<String, dynamic>? resultData;

  PatientLabModel({
    required this.testId,
    required this.testName,
    required this.status,
    this.completedAt,
    this.resultData,
  });

  factory PatientLabModel.fromJson(Map<String, dynamic> json) {
    // The PHP backend sends result_data as a JSON string, so we must decode it 
    // into a Dart Map to display the individual metrics (Hemoglobin, WBC, etc.)
    Map<String, dynamic>? parsedResults;
    if (json['result_data'] != null) {
      try {
        parsedResults = jsonDecode(json['result_data']);
      } catch (e) {
        print("Error parsing result_data JSON: $e");
      }
    }

    return PatientLabModel(
      testId: json['test_id'] ?? 0,
      testName: json['test_name'] ?? 'Unknown Test',
      status: json['status'] ?? 'PENDING',
      completedAt: json['completed_at'],
      resultData: parsedResults,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': testId,
      'test_name': testName,
      'status': status,
      'completed_at': completedAt,
      'result_data': resultData != null ? jsonEncode(resultData) : null,
    };
  }
}