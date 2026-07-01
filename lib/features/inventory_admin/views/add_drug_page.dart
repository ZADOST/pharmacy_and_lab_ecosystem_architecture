import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../models/drug_model.dart';

class AddDrugPage extends StatefulWidget {
  const AddDrugPage({Key? key}) : super(key: key);

  @override
  State<AddDrugPage> createState() => _AddDrugPageState();
}

class _AddDrugPageState extends State<AddDrugPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Text Controllers for our form fields
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _generatedQrHash;

  @override
  void dispose() {
    _brandNameController.dispose();
    _companyNameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Database Logic Connection: 
  // This function generates a distinct UUID which maps directly to the 
  // `qr_code_hash` column in our MySQL 'drugs' table, ensuring no two physical 
  // drug boxes ever share the same identifier.
  Future<void> _generateAndSaveDrug() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 1. Generate a completely distinct ID for this specific physical drug
      const uuid = Uuid();
      final String distinctHash = uuid.v4();

      // 2. Build the Model
      final newDrug = DrugModel(
        id: 0, // Auto-incremented by MySQL
        brandName: _brandNameController.text.trim(),
        companyName: _companyNameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        description: _descriptionController.text.trim(),
        qrCodeHash: distinctHash,
      );

      // 3. Send to PHP API
      final bool success = await ApiClient.addDrug(newDrug);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Show success and display the generated QR code to the pharmacist
        setState(() {
          _generatedQrHash = distinctHash;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drug successfully added to inventory!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add drug. Check database connection.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Drug Batch'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: The Form
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drug Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _brandNameController,
                      decoration: const InputDecoration(
                        labelText: 'Brand Name (e.g., Panadol Advance)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a brand name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company/Manufacturer (e.g., GSK)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a company name' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter price' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity Received',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter quantity' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Medical Description / Dosage Instructions',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _generateAndSaveDrug,
                        icon: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Icon(Icons.qr_code),
                        label: Text(
                          _isLoading ? 'Processing...' : 'Generate QR & Save to DB',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Right Side: The QR Code Display
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Distinct QR Label',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_generatedQrHash != null) ...[
                    QrImageView(
                      data: _generatedQrHash!,
                      version: QrVersions.auto,
                      size: 200.0,
                      foregroundColor: AppColors.primaryTeal,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ready to Print',
                      style: TextStyle(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hash: $_generatedQrHash',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                      ),
                    ),
                  ] else ...[
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Submit form to\ngenerate QR',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}