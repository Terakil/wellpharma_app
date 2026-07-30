import 'package:shared_preferences/shared_preferences.dart';

/// Gère l'URL de base de ton backend Express (server.js).
///
/// Par défaut :
/// - Émulateur Android -> http://10.0.2.2:3000 (10.0.2.2 pointe vers le
///   "localhost" de ta machine depuis l'émulateur)
/// - Simulateur iOS -> http://localhost:3000 fonctionne directement
/// - Téléphone physique -> remplace par l'adresse IP locale de ta machine,
///   ex: http://192.168.1.23:3000 (même réseau Wi-Fi que le serveur)
///
/// Modifiable directement dans l'app via l'écran "Paramètres".
class ApiConfig {
  ApiConfig._();
  static final ApiConfig instance = ApiConfig._();

  static const _prefsKey = 'wellpharma_api_base_url';
  static const defaultBaseUrl = 'http://10.0.2.2:3000';

  String _baseUrl = defaultBaseUrl;
  String get baseUrl => _baseUrl;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_prefsKey) ?? defaultBaseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    // Retire un éventuel "/" final pour rester cohérent dans les appels API.
    _baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    await prefs.setString(_prefsKey, _baseUrl);
  }
}
