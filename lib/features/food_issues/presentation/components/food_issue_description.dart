import 'package:flutter/material.dart';

import '../../domain/food_issue.dart';
import 'food_issue_section.dart';

class FoodIssueDescription extends StatelessWidget {
  const FoodIssueDescription({super.key, required this.report});
  final FoodIssue report;
  @override
  Widget build(BuildContext context) => FoodIssueSection(
    title: 'Deskripsi Makanan',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(report.menu, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(report.description, style: const TextStyle(height: 1.6)),
        const SizedBox(height: 12),
        Text(
          '${report.affectedPortions} porsi terdampak',
          style: const TextStyle(
            color: Color(0xFFAD3C25),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
