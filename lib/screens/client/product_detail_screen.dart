import 'package:flutter/material.dart';
import '../../config/formatters.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<List<Product>> _futureStock;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _futureStock = _api.getStock();
  }

  void _refreshStock() {
    setState(() {
      _futureStock = _api.getStock();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du produit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStock,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureStock,
        builder: (context, snapshot) {
          Product currentProduct = widget.product;
          
          if (snapshot.hasData) {
            // Rechercher le produit mis à jour dans la liste
            final updated = snapshot.data!.where((p) => p.designation == widget.product.designation).toList();
            if (updated.isNotEmpty) {
              currentProduct = updated.first;
            }
          }

          final isOutOfStock = currentProduct.quantite <= 0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Container(
                  height: 250,
                  width: double.infinity,
                  color: AppColors.primary.withValues(alpha: 0.05),
                  child: Image.network(
                    currentProduct.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.medication, size: 100, color: AppColors.primary),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Catégorie
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currentProduct.categorie,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Nom et Prix
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              currentProduct.designation,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textMain),
                            ),
                          ),
                          Text(
                            formatAr(currentProduct.prixUnitaire),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Stock Status (Temps réel via FutureBuilder)
                      Row(
                        children: [
                          Icon(
                            isOutOfStock ? Icons.error_outline : Icons.check_circle_outline,
                            size: 16,
                            color: isOutOfStock ? AppColors.accentRed : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOutOfStock ? "Stock épuisé" : "En stock (${currentProduct.quantite} unités)",
                            style: TextStyle(
                              color: isOutOfStock ? AppColors.accentRed : AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (snapshot.connectionState == ConnectionState.waiting)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Description
                      Text(
                        "Description",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textMain),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentProduct.description.isNotEmpty ? currentProduct.description : "Aucune description disponible pour ce produit.",
                        style: TextStyle(fontSize: 15, color: textDim, height: 1.5),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Référence
                      Text(
                        "Référence: ${currentProduct.reference}",
                        style: TextStyle(fontSize: 12, color: textDim, fontFamily: 'monospace'),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Bouton d'ajout
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isOutOfStock ? null : () {
                            context.read<CartService>().add(
                              currentProduct.designation, 
                              currentProduct.categorie, 
                              currentProduct.prixUnitaire, 
                              currentProduct.needsPrescription,
                              currentProduct.quantite,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${currentProduct.designation} ajouté au panier')),
                            );
                            _refreshStock(); // Re-vérifier après ajout
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOutOfStock ? textDim : AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: Text(
                            isOutOfStock ? "Indisponible" : "Ajouter au panier",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
