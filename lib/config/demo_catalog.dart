/// Catalogue "produits populaires" repris tel quel de public/html/acceuil.html.
/// Il n'existe pas encore de route API pour ce catalogue côté serveur
/// (seul /api/stock existe, pour la gestion interne). Cette liste locale
/// permet de garder l'écran Accueil pleinement fonctionnel en attendant
/// qu'une vraie route catalogue soit ajoutée au backend.
class DemoProduct {
  final String name;
  final String category;
  final String desc;
  final int price;
  const DemoProduct(this.name, this.category, this.desc, this.price);
}

const List<DemoProduct> demoPopularProducts = [
  DemoProduct('Doliprane 1000mg', 'Antalgique', 'Douleur et fièvre', 2000),
  DemoProduct('Fervex', 'Anti-grippe', 'Douleur et fièvre', 2000),
  DemoProduct('Paracétamol 500mg', 'Antalgique / Antipyrétique', 'Douleur et fièvre', 1000),
  DemoProduct('Vitascorbol 500mg', 'Vitamines', 'Fatigue, renforcement immunitaire', 15000),
  DemoProduct('Amoxicilline 500mg', 'Antibiotique', 'Infections bactériennes', 1000),
];

const List<String> categories = ['Médicaments', 'Homeopharma', 'Bébé'];
