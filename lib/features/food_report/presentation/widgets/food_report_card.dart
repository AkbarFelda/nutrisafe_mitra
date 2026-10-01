import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/food_report.dart';
import '../food_report_detail_page.dart';

class FoodReportCard extends StatelessWidget {
  const FoodReportCard({super.key, required this.report});

  final FoodReport report;

  void _showDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FoodReportDetailPage(report: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFD6F6FF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: AppIcon(AppAssets.schoolIcon, size: 26),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.school,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                report.address,
                style: const TextStyle(fontSize: 9.5, height: 1.25),
              ),
              const SizedBox(height: 4),
              Text(
                '${report.portions} Porsi',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _showDetail(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E74D2),
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 24),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Detail',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
