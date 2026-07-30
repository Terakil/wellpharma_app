import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _designationCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _quantiteCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _categorieCtrl = TextEditingController();
  final _api = ApiService();
  bool _saving = false;

  @override
  void dispose() {
    _designationCtrl.dispose();
    _prixCtrl.dispose();
    _quantiteCtrl.dispose();
    _descriptionCtrl.dispose();
    _categorieCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final product = Product(
        designation: _designationCtrl.text.trim(),
        prixUnitaire: num.parse(_prixCtrl.text.trim()),
        quantite: int.parse(_quantiteCtrl.text.trim()),
        reference: '',
        description: _descriptionCtrl.text.trim(),
        categorie: _categorieCtrl.text.trim(),
      );
      final message = await _api.addProduct(product);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un produit')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _designationCtrl,
                decoration: const InputDecoration(labelText: 'Désignation'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _prixCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Prix unitaire (Ar)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (num.tryParse(v.trim()) == null) return 'Nombre invalide';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _quantiteCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantité'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (int.tryParse(v.trim()) == null) return 'Nombre invalide';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _categorieCtrl,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description (optionnel)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
