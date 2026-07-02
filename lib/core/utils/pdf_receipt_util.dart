import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfReceiptUtil {
  /// Generates and triggers the native print/share dialog for the receipt
  static Future<void> generateAndPrintReceipt({
    required String drugName,
    required String companyName,
    required int quantity,
    required double pricePerUnit,
    required double totalPrice,
    int? patientId,
  }) async {
    final pdf = pw.Document();
    
    // Format the current date and time
    final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Standard 80mm thermal receipt printer format
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('PHARMACY & LAB ECOSYSTEM', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    pw.SizedBox(height: 4),
                    pw.Text('Erbil Central District', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Tel: +964 750 XXX XXXX', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              // Sale Metadata
              pw.Text('Date: $formattedDate', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Receipt No: #${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}', style: const pw.TextStyle(fontSize: 10)),
              if (patientId != null) 
                pw.Text('Patient ID: $patientId', style: const pw.TextStyle(fontSize: 10)),
              
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              // Items
              pw.Text('ITEM DISPENSED:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.SizedBox(height: 4),
              pw.Text('$drugName ($companyName)', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 4),
              
              // Pricing Breakdown
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('$quantity x \$${pricePerUnit.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('\$${totalPrice.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL DUE:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text('\$${totalPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),
              
              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Thank you for your visit.', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Wishing you good health.', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
                    pw.SizedBox(height: 12),
                    // Generates a scannable barcode for the receipt
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: 'RCPT-${DateTime.now().millisecondsSinceEpoch}',
                      width: 100,
                      height: 40,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // This triggers the native OS print dialog (works on Web, Windows, macOS, iOS, Android)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Pharmacy_Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}