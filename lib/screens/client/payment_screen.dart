import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/cart_service.dart';
import '../../services/invoice_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return Scaffold(
      appBar: AppBar(title: const Text("Paiement & Livraison")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Adresse de livraison", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain)),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: "Entrez votre adresse complète",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            Text("Résumé du paiement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain)),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Total à payer", style: TextStyle(color: textMain)),
              trailing: Text("${cart.total.toInt()} Ar", style: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                if (_addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez entrer une adresse")));
                  return;
                }
                
                final cartItems = cart.items;
                final total = cart.total;

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(child: CircularProgressIndicator()),
                );

                await Future.delayed(const Duration(seconds: 1)); // Simulation
                if (!mounted) return;
                Navigator.pop(context); // Fermer le loader

                await InvoiceService.generateAndPrintInvoice(cartItems, total.toDouble());
                
                if (!mounted) return;
                cart.clear();
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Commande confirmée !")));
              },
              child: const Text("Payer & Télécharger la facture", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
