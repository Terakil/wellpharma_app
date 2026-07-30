class Product {
  final int? idProduit;
  final String designation;
  final num prixUnitaire;
  final int quantite;
  final String reference;
  final String description;
  final String categorie;

  Product({
    this.idProduit,
    required this.designation,
    required this.prixUnitaire,
    required this.quantite,
    required this.reference,
    required this.description,
    required this.categorie,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProduit: json['id_produit'] is int
          ? json['id_produit'] as int
          : int.tryParse('${json['id_produit'] ?? ''}'),
      designation: json['designation']?.toString() ?? '',
      prixUnitaire: num.tryParse('${json['prix_unitaire'] ?? 0}') ?? 0,
      quantite: int.tryParse('${json['quantite'] ?? 0}') ?? 0,
      reference: json['reference']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categorie: json['categorie']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'designation': designation,
        'prix_unitaire': prixUnitaire,
        'quantite': quantite,
        'description': description,
        'categorie': categorie,
      };

  /// Statut d'affichage, même logique que public/html/stock.html
  StockStatus get status {
    if (quantite >= 100) return StockStatus.enStock;
    if (quantite > 0) return StockStatus.faible;
    return StockStatus.rupture;
  }
}

enum StockStatus { enStock, faible, rupture }
