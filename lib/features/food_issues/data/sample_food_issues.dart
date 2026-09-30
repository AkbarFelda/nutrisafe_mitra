import '../domain/food_issue.dart';

final sampleFoodIssues = List<FoodIssue>.unmodifiable([
  FoodIssue(
    id: 'LM-003',
    reporter: 'Siti Aminah',
    problem: 'Kemasan makanan terbuka',
    school: 'SDN 1 Subang',
    date: DateTime(2026, 3, 23, 11, 45),
    menu: 'Nasi dan telur rebus',
    description: 'Beberapa kemasan makanan terbuka saat diterima sekolah.',
    affectedPortions: 12,
    status: FoodIssueStatus.pending,
  ),
  FoodIssue(
    id: 'LM-002',
    reporter: 'Budi Santoso',
    problem: 'Makanan berbau tidak sedap',
    school: 'SMPN 1 Subang',
    date: DateTime(2026, 3, 22, 12, 15),
    menu: 'Sayur capcay',
    description:
        'Makanan dilaporkan berbau tidak seperti biasanya saat pembagian.',
    affectedPortions: 8,
    status: FoodIssueStatus.inProgress,
  ),
  FoodIssue(
    id: 'LM-001',
    reporter: 'Rina Wulandari',
    problem: 'Kemasan susu bocor',
    school: 'SDN 1 Subang',
    date: DateTime(2026, 3, 21, 10, 30),
    menu: 'Susu kemasan',
    description: 'Kemasan bocor. Porsi pengganti sudah diterima pihak sekolah.',
    affectedPortions: 4,
    status: FoodIssueStatus.resolved,
  ),
]);
