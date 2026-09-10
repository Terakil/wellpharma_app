import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Analyse le texte de l'image de manière stricte et sécurisée via Google ML Kit
  /// pour éviter qu'une bouteille d'eau ou un faux document ne passe pour une ordonnance.
  Future<bool> isPrescription(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text.toLowerCase();
      
      // Mots-clés hautement spécifiques et médicaux requis sur une ordonnance française/malgache
      final strictMedicalKeywords = [
        'ordonnance',
        'docteur',
        'médecin',
        'posologie',
        'comprimé',
        'gélule',
        'comprimés',
        'gélules',
        'ordonnance médicale',
        'clinique',
        'infirmier',
        'hospital',
        'hopital',
        'dr.',
        'dr ',
        'médicament',
        'médicaments',
        'matin',
        'midi',
        'soir',
        'pendant',
        'cure',
        'voie orale',
        'mg/ml',
      ];

      // Mots-clés qui indiquent un faux document commercial ou alimentaire (ex: bouteille d'eau)
      final blacklistKeywords = [
        'ingrédients',
        'valeurs nutritionnelles',
        'source',
        'embouteillée',
        'conservation',
        'calcium',
        'magnésium',
        'sodium',
        'potassium',
        'bicarbonates',
        'litres',
        'volvic',
        'viva',
        'eau de source',
        'minérale',
        'eaux',
      ];

      // Si le texte contient des mots-clés de bouteille ou d'aliment, on rejette immédiatement
      for (var blacklisted in blacklistKeywords) {
        if (fullText.contains(blacklisted)) {
          print("❌ Rejeté : Détection d'un produit alimentaire ou commercial ($blacklisted)");
          return false;
        }
      }

      // Compter les vrais mots-clés médicaux présents
      int medicalMatchCount = 0;
      for (var word in strictMedicalKeywords) {
        if (fullText.contains(word)) {
          medicalMatchCount++;
        }
      }

      print("OCR Text detected length: ${fullText.length} characters");
      print("Medical keywords matched: $medicalMatchCount");

      // Sécurité Robuste :
      // Il faut au moins 2 mots-clés purement médicaux ou des indices de traitement (ex: posologie + matin)
      // pour éviter les faux positifs d'une simple bouteille d'eau ou magazine.
      return medicalMatchCount >= 2;
    } catch (e) {
      print("Error during OCR scanning: $e");
      return false; // Par sécurité en cas d'erreur
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
