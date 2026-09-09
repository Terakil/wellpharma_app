import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cart_item.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class InvoiceService {
  /// Génère un ticket de caisse étroit (80mm) avec logos
  static Future<void> generateAndPrintInvoice(List<CartItem> items, double total) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(now);

    // Chargement des logos
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );
    final logo2Image = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo2.png')).buffer.asUint8List(),
    );
    final logoIspmImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo_ispm.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logos à la normale (non circulaires pour la facture)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(logoImage, height: 30),
                  pw.SizedBox(width: 8),
                  pw.Image(logo2Image, height: 30),
                  pw.SizedBox(width: 8),
                  pw.Image(logoIspmImage, height: 30),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Column(
                children: [
                  pw.Text("WELLPHARMA", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                  pw.Text("Votre santé, notre priorité", style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 5),
                  pw.Text("TICKET DE CAISSE", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(thickness: 0.5),
                ],
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text("Date: $dateStr", style: const pw.TextStyle(fontSize: 8)),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Article", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Total", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(thickness: 0.5),
              ...items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text("${item.name} x${item.quantity}", style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Text("${item.total.toStringAsFixed(0)} Ar", style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              )),
              pw.Divider(thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTAL", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text("${total.toStringAsFixed(0)} Ar", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text("Merci de votre visite !", style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: 'WP-${now.millisecondsSinceEpoch}',
                  width: 80,
                  height: 30,
                ),
              ),
            ],
          );
        },
      ),
    );

    // On force le format Petit Ticket (80mm) dans l'appel à Printing.layoutPdf
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Ticket_WellPharma_${now.millisecondsSinceEpoch}',
      format: PdfPageFormat.roll80,
    );
  }
}
