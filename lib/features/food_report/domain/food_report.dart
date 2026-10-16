class FoodReport {
  const FoodReport({
    this.id,
    required this.date,
    required this.school,
    required this.address,
    required this.portions,
    this.status,
    this.distributedPortions,
    this.studentsWithAllergies,
    this.allergies = const [],
    this.menuItems = const [],
    this.documentationPhotos = const [],
  });

  final int? id;
  final DateTime date;
  final String school;
  final String address;
  final int portions;
  final FoodReportStatus? status;
  final int? distributedPortions;
  final int? studentsWithAllergies;
  final List<FoodReportAllergy> allergies;
  final List<FoodReportMenuItem> menuItems;
  final List<String> documentationPhotos;

  int? get distributionPercentage {
    final distributed = distributedPortions;
    if (distributed == null || portions <= 0) return null;
    return (distributed / portions * 100).round();
  }
}

enum FoodReportStatus { pending, received, rejected }

class FoodReportAllergy {
  const FoodReportAllergy({required this.name, required this.students});

  final String name;
  final int students;
}

class FoodReportMenuItem {
  const FoodReportMenuItem({
    required this.name,
    required this.portions,
    this.category = '',
  });

  final String name;
  final String category;
  final int portions;
}

const foodReportMonths = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String foodReportPeriod(DateTime date) =>
    '${foodReportMonths[date.month - 1]} ${date.year}';

String foodReportDate(DateTime date) => '${date.day} ${foodReportPeriod(date)}';
