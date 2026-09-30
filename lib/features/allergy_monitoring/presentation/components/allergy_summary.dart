import 'package:flutter/material.dart';

import '../../domain/allergy_monitoring.dart';

class AllergySummary extends StatelessWidget {
  const AllergySummary({super.key, required this.data});
  final AllergyMonitoringData data;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final width = constraints.maxWidth < 330 * scale
          ? constraints.maxWidth
          : (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: width,
            child: _Metric(
              title: 'Jenis Alergi',
              value: data.types.length,
              unit: 'jenis alergi',
              icon: Icons.category_rounded,
              color: const Color(0xFFFF777B),
            ),
          ),
          SizedBox(
            width: width,
            child: _Metric(
              title: 'Total Siswa Alergi',
              value: data.allergicStudents,
              unit: 'siswa',
              icon: Icons.school_rounded,
              color: const Color(0xFFFFB58F),
            ),
          ),
        ],
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
  final String title, unit;
  final int value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, size: 28, color: const Color(0xFF34285A)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(unit, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
