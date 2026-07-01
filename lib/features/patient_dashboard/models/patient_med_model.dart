class PatientMedModel {
  final int saleId;
  final String brandName;
  final int quantity;
  final String saleDate;
  final String description;

  PatientMedModel({
    required this.saleId,
    required this.brandName,
    required this.quantity,
    required this.saleDate,
    required this.description,
  });

  factory PatientMedModel.fromJson(Map<String, dynamic> json) {
    return PatientMedModel(
      saleId: json['sale_id'] ?? 0,
      brandName: json['brand_name'] ?? 'Unknown Medication',
      quantity: json['quantity'] ?? 1,
      saleDate: json['sale_date'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sale_id': saleId,
      'brand_name': brandName,
      'quantity': quantity,
      'sale_date': saleDate,
      'description': description,
    };
  }
}