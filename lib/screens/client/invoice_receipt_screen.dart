import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../config/theme.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import 'dart:typed_data';

class InvoiceReceiptScreen extends StatefulWidget {
  final List<CartItem> items;
  final double total;

  const InvoiceReceiptScreen({
    super.key,
    required this.items,
    required this.total,
  });

  @override
  State<InvoiceReceiptScreen> createState() => _InvoiceReceiptScreenState();
}

class _InvoiceReceiptScreenState extends State<InvoiceReceiptScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _captureAndSave() async {
    try {
      RenderRepaintBoundary boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Partage de l'image via le package Printing
      await Printing.sharePdf(
        bytes: pngBytes,
        filename: 'Facture_WellPharma_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Facture prête à être enregistrée !")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de capture : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma Facture"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _captureAndSave,
            tooltip: "Télécharger comme image",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: RepaintBoundary(
            key: _boundaryKey,
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png', height: 40),
                      const SizedBox(width: 10),
                      Image.asset('assets/images/logo2.png', height: 40),
                      const SizedBox(width: 10),
                      Image.asset('assets/images/logo_ispm.png', height: 40),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "WELLPHARMA",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    "Votre santé, notre priorité",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Divider(height: 32, thickness: 1),
                  const Text(
                    "TICKET DE CAISSE",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Date : $dateStr", style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 24),
                  
                  // Liste des articles
                  ...widget.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${item.name} x${item.quantity}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          "${item.total.toStringAsFixed(0)} Ar",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
                  
                  const Divider(height: 32, thickness: 1),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        "${widget.total.toStringAsFixed(0)} Ar",
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    "Merci de votre visite !",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  
                  // Petit "faux" code barre pour le look
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text("|| ||| | || |||| | ||", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: _captureAndSave,
              icon: const Icon(Icons.image),
              label: const Text("TÉLÉCHARGER LA FACTURE (IMAGE)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("RETOUR À L'ACCUEIL"),
            ),
          ],
        ),
      ),
    );
  }
}
