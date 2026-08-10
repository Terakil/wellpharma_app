import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Analyse le texte de l'image pour détecter si c'est une ordonnance
  Future<bool> isPrescription(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text.toLowerCase();
      
      // Liste de mots-clés typiques d'une ordonnance (en français)
      final keywords = [
        'ordonnance',
        'docteur',
        'médecin',
        'médicament',
        'patient',
        'posologie',
        'cachet',
        'signature',
        'clinique',
        'santé',
        'rp', // "Recipe" souvent utilisé
        'mg', // Milligrammes
      ];

      // On compte combien de mots-clés sont présents
      int matchCount = 0;
      for (var word in keywords) {
        if (fullText.contains(word)) {
          matchCount++;
        }
      }

      print("OCR Text detected: ${fullText.length} characters");
      print("Prescription keywords matched: $matchCount");

      // Si on trouve au moins 2 mots-clés, on considère que c'est une ordonnance
      return matchCount >= 2;
    } catch (e) {
      print("Error during OCR scanning: $e");
      return false;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
