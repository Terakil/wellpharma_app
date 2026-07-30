import 'package:flutter/material.dart';
import '../../config/formatters.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import 'add_product_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => StockScreenState();
}

class StockScreenState extends State<StockScreen> {
  final _api = ApiService();
  late Future<List<Product>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _api.getStock();
  }

  void reload() {
    setState(() => _future = _api.getStock());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock global'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: reload,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (added == true) reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: textDim),
                hintText: 'Rechercher par médicament ou référence...',
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorState(message: snapshot.error.toString(), onRetry: reload);
                }
                final products = (snapshot.data ?? [])
                    .where((p) =>
                        _query.isEmpty ||
                        p.designation.toLowerCase().contains(_query) ||
                        p.reference.toLowerCase().contains(_query))
                    .toList();
                if (products.isEmpty) {
                  return Center(
                    child: Text('Aucun produit trouvé', style: TextStyle(color: textDim)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => reload(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _StockTile(product: products[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StockTile extends StatelessWidget {
  final Product product;
  const _StockTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    late Color color;
    late String label;
    switch (product.status) {
      case StockStatus.enStock:
        color = AppColors.primary;
        label = 'En stock';
        break;
      case StockStatus.faible:
        color = const Color(0xFFF59E0B);
        label = 'Faible';
        break;
      case StockStatus.rupture:
        color = AppColors.accentRed;
        label = 'Rupture';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.designation,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(product.description.isEmpty ? product.categorie : product.description,
                      style: TextStyle(color: textDim, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text('Réf. ${product.reference}',
                      style: TextStyle(
                          color: textDim, fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatAr(product.prixUnitaire),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${product.quantite} u.', style: TextStyle(color: textDim, fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: AppColors.accentRed, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: textDim)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
