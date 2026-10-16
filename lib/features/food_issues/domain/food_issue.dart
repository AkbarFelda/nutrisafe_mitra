enum FoodIssueStatus { pending, inProgress, resolved }

class FoodIssue {
  const FoodIssue({
    required this.id,
    required this.school,
    required this.date,
    required this.menu,
    required this.description,
    required this.affectedPortions,
    required this.status,
    this.reporter = 'Pelapor belum dicantumkan',
    this.problem = 'Masalah pada makanan',
    this.photoUrls = const [],
  });

  final String reporter;
  final String problem;
  final List<String> photoUrls;
  final String id;
  final String school;
  final DateTime date;
  final String menu;
  final String description;
  final int affectedPortions;
  final FoodIssueStatus status;
}

String foodIssueDateTime(DateTime date) {
  const months = [
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
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year} \u2022 $hour.$minute';
}
