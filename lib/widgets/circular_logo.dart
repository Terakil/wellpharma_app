import 'package:flutter/material.dart';
import '../config/theme.dart';

class CircularLogo extends StatelessWidget {
  final String assetPath;
  final double size;
  final bool hasBorder;

  const CircularLogo({
    super.key,
    required this.assetPath,
    this.size = 50,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 20),
        ),
      ),
    );
  }
}
