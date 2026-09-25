import '../domain/food_report.dart';

final sampleFoodReports = List<FoodReport>.unmodifiable([
  for (final day in [23, 22, 21]) ...[
    FoodReport(
      date: DateTime(2026, 3, day),
      school: 'SDN 1 Subang',
      address: 'Jl. H.O. Iskandar, Desa No.60, Subang, Kec. Subang, Kabupaten Subang, Jawa Barat 45586',
      portions: 196,
    ),
    FoodReport(
      date: DateTime(2026, 3, day),
      school: 'SMPN 1 Subang',
      address: 'Jl. Letjen Suprapto No.105, Karanganyar, Kec. Subang, Kabupaten Subang, Jawa Barat 41211',
      portions: 360,
    ),
  ],
]);
