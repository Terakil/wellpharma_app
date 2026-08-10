import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class LoginResult {
  final bool success;
  final String? role;
  final String? redirect;
  final String? message;
  LoginResult({required this.success, this.role, this.redirect, this.message});
}

/// Toute la communication avec ton backend server.js passe par ici.
/// Les 3 routes existantes sont : POST /api/login, GET /api/stock,
/// POST /api/ajout.
class ApiService {
  String get _base => ApiConfig.instance.baseUrl;

  Future<LoginResult> login(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return LoginResult(
          success: true,
          role: data['role']?.toString(),
          redirect: data['redirect']?.toString(),
        );
      }
      return LoginResult(
        success: false,
        message: data['message']?.toString() ?? 'Identifiants invalides',
      );
    } catch (e) {
      throw ApiException(
        'Impossible de contacter le serveur ($_base). '
        'Vérifie l\'URL dans Paramètres et que le backend tourne.',
      );
    }
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'nom': name, 'email': email, 'motdepasse': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 || data['success'] == true) {
        return true;
      }
      throw ApiException(data['message']?.toString() ?? 'Erreur lors de l\'inscription');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la création du compte sur $_base. Vérifie que la route /api/signup existe.');
    }
  }

  Future<List<Product>> getStock() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/stock'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw ApiException('Erreur serveur (${res.statusCode})');
      }
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Impossible de charger le stock depuis $_base. '
        'Vérifie la connexion réseau et l\'URL du serveur.',
      );
    }
  }

  Future<String> addProduct(Product product) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/ajout'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(product.toCreateJson()),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return data['message']?.toString() ?? 'Produit ajouté';
      }
      throw ApiException(data['error']?.toString() ?? 'Erreur lors de l\'ajout');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Impossible d\'ajouter le produit ($_base).');
    }
  }

  Future<void> processOrder(List<CartItem> items, String email) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/commander'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'items': items.map((i) => {'name': i.name, 'quantity': i.quantity}).toList(),
              'email': email,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || data['success'] != true) {
        throw ApiException(data['message']?.toString() ?? 'Échec de la commande');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la validation de la commande.');
    }
  }

  Future<List<dynamic>> getOrderHistory(String email) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/historique?email=$email'))
          .timeout(const Duration(seconds: 10));
      
      if (res.statusCode != 200) {
        throw ApiException('Erreur serveur (${res.statusCode})');
      }
      return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      throw ApiException('Impossible de charger l\'historique.');
    }
  }
}
