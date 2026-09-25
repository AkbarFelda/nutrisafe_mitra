import '../domain/food_report.dart';

final sampleFoodReports = List<FoodReport>.unmodifiable([
  for (final day in [23, 22, 21]) ...[
    FoodReport(
      date: DateTime(2026, 3, day),
      school: 'SDN 1 Subang',
      address: 'Jl. H.O. Iskandar, Desa No.60, Subang, Kec. Subang, Kabupaten Subang, Jawa Barat 45586',
      portions: 196,
      status: FoodReportStatus.received,
      distributedPortions: 196,
      studentsWithAllergies: 9,
      allergies: _sampleAllergies,
      menuItems: _sampleMenuItems(196),
    ),
    FoodReport(
      date: DateTime(2026, 3, day),
      school: 'SMPN 1 Subang',
      address: 'Jl. Letjen Suprapto No.105, Karanganyar, Kec. Subang, Kabupaten Subang, Jawa Barat 41211',
      portions: 360,
      status: FoodReportStatus.received,
      distributedPortions: 360,
      studentsWithAllergies: 9,
      allergies: _sampleAllergies,
      menuItems: _sampleMenuItems(360),
    ),
  ],
]);

const _sampleAllergies = [
  FoodReportAllergy(name: 'Kacang', students: 5),
  FoodReportAllergy(name: 'Telur', students: 4),
];

List<FoodReportMenuItem> _sampleMenuItems(int portions) => List.unmodifiable([
  FoodReportMenuItem(
    name: 'Nasi Putih',
    category: 'Karbohidrat',
    portions: portions,
  ),
  FoodReportMenuItem(
    name: 'Telur Rebus',
    category: 'Protein Hewani',
    portions: portions,
  ),
  FoodReportMenuItem(name: 'Capcay', category: 'Sayuran', portions: portions),
  FoodReportMenuItem(name: 'Jeruk', category: 'Buah', portions: portions),
  FoodReportMenuItem(name: 'Susu Kemasan', portions: portions),
  const FoodReportMenuItem(
    name: 'Menu Pengganti (Tanpa Telur)',
    category: 'Khusus Siswa Alergi',
    portions: 4,
  ),
]);
