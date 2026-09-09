import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../services/scan_service.dart';
import '../../services/session_service.dart';
import '../../widgets/circular_logo.dart';
import '../../models/cart_item.dart';
import 'invoice_receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _addressController = TextEditingController();
  final _scanService = ScanService();
  final _api = ApiService();
  File? _prescriptionImage;
  bool _isScanning = false;
  bool _prescriptionValidated = false;

  Future<void> _pickAndScanImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _prescriptionImage = File(pickedFile.path);
        _isScanning = true;
      });

      final isValid = await _scanService.isPrescription(_prescriptionImage!);

      setState(() {
        _isScanning = false;
        _prescriptionValidated = isValid;
      });

      if (!isValid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("L'image ne semble pas être une ordonnance valide."),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final needsScan = cart.requiresPrescription;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircularLogo(assetPath: 'assets/images/logo.png', size: 45),
            const SizedBox(width: 8),
            Image.asset('assets/images/logo2.png', height: 40),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircularLogo(assetPath: 'assets/images/logo_ispm.png', size: 40),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Adresse de livraison", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain)),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(hintText: "Entrez votre adresse complète"),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            if (needsScan) ...[
              Text("Ordonnance requise", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentRed)),
              const SizedBox(height: 8),
              const Text("Certains articles dans votre panier nécessitent une ordonnance médicale.", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    if (_prescriptionImage != null)
                      Container(
                        height: 150,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _prescriptionValidated ? AppColors.primary : AppColors.accentRed),
                          image: DecorationImage(image: FileImage(_prescriptionImage!), fit: BoxFit.cover),
                        ),
                        child: _isScanning 
                          ? const Center(child: CircularProgressIndicator()) 
                          : Icon(
                              _prescriptionValidated ? Icons.check_circle : Icons.error, 
                              color: _prescriptionValidated ? AppColors.primary : AppColors.accentRed, 
                              size: 40
                            ),
                      ),
                    ElevatedButton.icon(
                      onPressed: _pickAndScanImage,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(_prescriptionImage == null ? "Scanner mon ordonnance" : "Scanner à nouveau"),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text("Résumé du paiement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain)),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Total à payer", style: TextStyle(color: textMain)),
              trailing: Text("${cart.total.toInt()} Ar", style: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (needsScan && !_prescriptionValidated) ? null : () async {
                  if (_addressController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez entrer une adresse")));
                    return;
                  }
                  
                  showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator()));
                  
                  try {
                    final session = context.read<SessionService>();
                    await _api.processOrder(cart.items, session.email ?? 'anonyme');

                    if (!mounted) return;
                    Navigator.pop(context);

                    // Navigation vers la nouvelle interface de facture image
                    final items = List<CartItem>.from(cart.items);
                    final total = cart.total.toDouble();
                    
                    cart.clear();
                    
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => InvoiceReceiptScreen(items: items, total: total),
                      ),
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Commande validée !")));
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.accentRed,
                    ));
                  }
                },
                child: const Text("Payer & Télécharger la facture", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
