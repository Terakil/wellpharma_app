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
        title: const Text("Aide & FAQ"),
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
              "Comment pouvons-nous vous aider ?",
              style: TextStyle(fontSize: 16, color: textDim),
            ),
            const SizedBox(height: 30),
            _buildFaqItem(
              "Comment passer une commande ?",
              "Pour passer une commande, sélectionnez le produit souhaité, cliquez sur \"Ajouter au panier\", puis rendez-vous dans votre panier pour finaliser.",
              bgSide,
              textMain,
              textDim,
              isDark,
            ),
            _buildFaqItem(
              "Comment modifier mes informations personnelles ?",
              "Allez dans \"Paramètres\" pour mettre à jour votre nom ou d'autres informations de profil.",
              bgSide,
              textMain,
              textDim,
              isDark,
            ),
            _buildFaqItem(
              "Comment activer ou désactiver les notifications ?",
              "Dans \"Paramètres\", vous trouverez prochainement les options pour gérer vos notifications.",
              bgSide,
              textMain,
              textDim,
              isDark,
            ),
            _buildFaqItem(
              "Que faire si je rencontre un problème avec ma commande ?",
              "Contactez notre support via le formulaire de contact disponible ou envoyez un email à support@wellpharma.com.",
              bgSide,
              textMain,
              textDim,
              isDark,
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
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
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
