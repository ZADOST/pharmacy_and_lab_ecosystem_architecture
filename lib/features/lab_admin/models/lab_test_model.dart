class LabTestModel {
  final int testId;
  final int patientId;
  final String testName;
  final String status;
  final String? resultData;

  LabTestModel({
    required this.testId,
    required this.patientId,
    required this.testName,
    required this.status,
    this.resultData,
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    return LabTestModel(
      testId: json['test_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      testName: json['test_name'] ?? '',
      status: json['status'] ?? 'PENDING',
      resultData: json['result_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': testId,
      'patient_id': patientId,
      'test_name': testName,
      'status': status,
      'result_data': resultData,
    };
  }
}