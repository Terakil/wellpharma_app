import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final bgSide = isDark ? AppColors.bgSideDark : AppColors.bgSideLight;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "WellPharma Aide",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              "Découvrez les fonctionnalités de votre application.",
              style: TextStyle(fontSize: 16, color: textDim),
            ),
            const SizedBox(height: 30),
            _buildFaqItem(
              "Recherche et Catégories",
              "Utilisez la barre de recherche en haut de l'accueil ou cliquez sur l'onglet 'Recherche' en bas pour trouver un médicament. Vous pouvez aussi filtrer par catégorie en cliquant sur les boutons (Antibiotique, Vitamines, etc.).",
              bgSide, textMain, textDim, isDark,
            ),
            _buildFaqItem(
              "Commande et Panier",
              "Ajoutez des produits au panier via le bouton '+'. Le bouton panier en haut à droite (ou l'onglet en bas) vous permet de voir vos articles et de valider votre achat.",
              bgSide, textMain, textDim, isDark,
            ),
            _buildFaqItem(
              "Scan d'Ordonnance",
              "Pour certains médicaments sensibles (ex: Augmentin), un scan d'ordonnance est obligatoire lors du paiement. L'IA vérifiera la validité du document via votre caméra.",
              bgSide, textMain, textDim, isDark,
            ),
            _buildFaqItem(
              "Gestion du Stock",
              "Chaque achat validé diminue automatiquement le stock réel dans la base de données MySQL de la pharmacie.",
              bgSide, textMain, textDim, isDark,
            ),
            _buildFaqItem(
              "Thème et Profil",
              "Dans les paramètres, vous pouvez basculer entre le mode clair et sombre, changer votre photo de profil (Galerie) et mettre à jour votre nom d'affichage.",
              bgSide, textMain, textDim, isDark,
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.support_agent, size: 50, color: AppColors.primary),
                  const SizedBox(height: 10),
                  Text("Encore besoin d'aide ?", style: TextStyle(color: textMain)),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Contacter le support", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, Color bgSide, Color textMain, Color textDim, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgSide,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textMain),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(color: textDim, height: 1.4),
          ),
        ],
      ),
    );
  }
}
