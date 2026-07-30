import 'package:intl/intl.dart';

final _priceFormat = NumberFormat.decimalPattern('fr_FR');

/// Reproduit formatPrice() de public/js/app.js -> "12 000 Ar"
String formatAr(num value) => '${_priceFormat.format(value)} Ar';
