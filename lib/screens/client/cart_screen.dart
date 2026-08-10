import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/formatters.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../models/product.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            const SizedBox(width: 8),
            Image.asset('assets/images/logo2.png', height: 40),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('assets/images/logo_ispm.png', height: 40),
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? const _EmptyCart()
          : FutureBuilder<List<Product>>(
              future: ApiService().getStock(),
              builder: (context, snapshot) {
                final stockMap = {for (var p in snapshot.data ?? []) p.designation: p.quantite};

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final item = cart.items[i];
                          final maxStock = stockMap[item.name] ?? 999;

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.medication_liquid,
                                        color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text(item.category,
                                            style: TextStyle(
                                                color: textDim, fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(formatAr(item.price),
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                                        onPressed: () => context.read<CartService>().decrement(item),
                                      ),
                                      Text('${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 20),
                                        onPressed: item.quantity >= maxStock ? null : () => context.read<CartService>().increment(item, maxStock),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _CartSummary(total: cart.total, isDark: isDark, textMain: textMain, textDim: textDim),
                  ],
                );
              },
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 56, color: textDim.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text('Ton panier est vide', style: TextStyle(color: textDim)),
          const SizedBox(height: 4),
          Text('Ajoute des produits depuis l\'accueil',
              style: TextStyle(color: textDim, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final num total;
  final bool isDark;
  final Color textMain;
  final Color textDim;
  
  const _CartSummary({
    required this.total,
    required this.isDark,
    required this.textMain,
    required this.textDim,
  });

  @override
  Widget build(BuildContext context) {
    final bgSide = isDark ? AppColors.bgSideDark : AppColors.bgSideLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: bgSide,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(color: textDim)),
              Text(formatAr(total),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaymentScreen()),
            ),
            child: const Text('Passer la commande'),
          ),
        ],
      ),
    );
  }
}
