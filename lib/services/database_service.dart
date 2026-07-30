import '../models/medication.dart';

class DatabaseService {
  static final List<Medication> _mockDb = [
    Medication(id: '1', name: 'Doliprane 1000mg', category: 'Antalgique', price: 2000, image: 'assets/images/minia.png', stock: 100, sales: 15),
    Medication(id: '2', name: 'FERVEX', category: 'Anti-grippe', price: 2000, image: 'assets/images/minia.png', stock: 50, sales: 45),
    Medication(id: '3', name: 'Paracétamol 500mg', category: 'Antalgique / Antipyrétique', price: 1000, image: 'assets/images/minia.png', stock: 80, sales: 30),
    Medication(id: '4', name: 'Vitascorbol 500mg', category: 'Vitamines', price: 15000, image: 'assets/images/minia.png', stock: 30, sales: 10),
    Medication(id: '5', name: 'Amoxicilline 500mg', category: 'Antibiotique', price: 1000, image: 'assets/images/minia.png', stock: 40, sales: 25),
  ];

  static const List<String> categories = [
    'Antalgique',
    'Anti-grippe',
    'Antalgique / Antipyrétique',
    'Vitamines',
    'Antibiotique',
    'Infections bactériennes',
    'Douleur et fièvre',
  ];

  Future<List<Medication>> fetchMedications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockDb);
  }

  Future<void> updateStock(String id, int newStock) async {
    final index = _mockDb.indexWhere((m) => m.id == id);
    if (index != -1) {
      _mockDb[index].stock = newStock;
    }
  }

  Future<void> addMedication(Medication med) async {
    _mockDb.add(med);
  }
}
