import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/qr_scanner_util.dart';
import '../../../core/utils/pdf_receipt_util.dart'; // <-- New Import
import '../models/drug_model.dart';

class DispenseDrugPage extends StatefulWidget {
  const DispenseDrugPage({Key? key}) : super(key: key);

  @override
  State<DispenseDrugPage> createState() => _DispenseDrugPageState();
}

class _DispenseDrugPageState extends State<DispenseDrugPage> {
  DrugModel? _scannedDrug;
  bool _isLoading = false;
  int _quantityToSell = 1;
  final TextEditingController _patientIdController = TextEditingController();

  @override
  void dispose() {
    _patientIdController.dispose();
    super.dispose();
  }

  Future<void> _startBarcodeScan() async {
    final String? scannedHash = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (scannedHash != null) {
      setState(() => _isLoading = true);
      
      final drug = await ApiClient.getDrugByQr(scannedHash);
      
      setState(() {
        _scannedDrug = drug;
        _isLoading = false;
        _quantityToSell = 1;
      });

      if (drug == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unrecognized QR Code. Drug not in database.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _completeSale() async {
    if (_scannedDrug == null) return;

    if (_quantityToSell > _scannedDrug!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Not enough stock available!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final double total = _scannedDrug!.price * _quantityToSell;
    final int? optionalPatientId = int.tryParse(_patientIdController.text.trim());

    final success = await ApiClient.processSale(
      drugId: _scannedDrug!.id,
      patientId: optionalPatientId,
      quantity: _quantityToSell,
      totalPrice: total,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale processed successfully! Generating receipt...'),
          backgroundColor: AppColors.successGreen,
        ),
      );

      // Trigger the PDF Receipt Generation
      await PdfReceiptUtil.generateAndPrintReceipt(
        drugName: _scannedDrug!.brandName,
        companyName: _scannedDrug!.companyName,
        quantity: _quantityToSell,
        pricePerUnit: _scannedDrug!.price,
        totalPrice: total,
        patientId: optionalPatientId,
      );

      // Clear the screen for the next customer
      setState(() {
        _scannedDrug = null;
        _patientIdController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to process sale. Check connection.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Point of Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _startBarcodeScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Drug Box', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 32),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_scannedDrug != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _scannedDrug!.brandName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _scannedDrug!.companyName,
                        style: TextStyle(fontSize: 16, color: AppColors.textLight),
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Current Stock:', style: TextStyle(fontSize: 16)),
                          Text(
                            '${_scannedDrug!.stock} units',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _scannedDrug!.stock < 5 ? Colors.red : AppColors.successGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Unit Price:', style: TextStyle(fontSize: 16)),
                          Text('\$${_scannedDrug!.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _patientIdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Patient ID (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (_quantityToSell > 1) {
                              setState(() => _quantityToSell--);
                            }
                          },
                        ),
                        Text('$_quantityToSell', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() => _quantityToSell++);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: \$${(_scannedDrug!.price * _quantityToSell).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    ElevatedButton(
                      onPressed: _completeSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Confirm Sale & Print', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Text(
                    'Scan a drug to begin transaction.',
                    style: TextStyle(fontSize: 18, color: AppColors.textLight),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}