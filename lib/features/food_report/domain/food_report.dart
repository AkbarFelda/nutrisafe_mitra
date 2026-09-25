class FoodReport {
  const FoodReport({
    required this.date,
    required this.school,
    required this.address,
    required this.portions,
  });

  final DateTime date;
  final String school;
  final String address;
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
