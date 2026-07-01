class DrugModel {
  final int id;
  final String brandName;
  final String companyName;
  final double price;
  final String qrCodeHash;
  final int stock;
  final String description;

  DrugModel({
    required this.id,
    required this.brandName,
    required this.companyName,
    required this.price,
    required this.qrCodeHash,
    required this.stock,
    required this.description,
  });

  factory DrugModel.fromJson(Map<String, dynamic> json) {
    return DrugModel(
      id: json['drug_id'] ?? 0,
      brandName: json['brand_name'] ?? '',
      companyName: json['company_name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      qrCodeHash: json['qr_code_hash'] ?? '',
      stock: json['total_stock'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drug_id': id,
      'brand_name': brandName,
      'company_name': companyName,
      'price': price,
      'qr_code_hash': qrCodeHash,
      'total_stock': stock,
      'description': description,
    };
  }
}