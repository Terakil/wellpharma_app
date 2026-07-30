import 'package:flutter/material.dart';
import '../config/formatters.dart';
import '../config/theme.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String category;
  final String desc;
  final num price;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.name,
    required this.category,
    required this.desc,
    required this.price,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medication, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            Text(
              category,
              style: TextStyle(color: textDim, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatAr(price),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13),
                ),
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
