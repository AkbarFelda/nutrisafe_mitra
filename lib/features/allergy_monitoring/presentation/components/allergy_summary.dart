import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/allergy_monitoring.dart';

class AllergySummary extends StatelessWidget {
  const AllergySummary({super.key, required this.data});
  final AllergyMonitoringData data;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final useSingleColumn = constraints.maxWidth < 330 * scale;
      final allergyTypeCard = _Metric(
        title: 'Jenis Alergi',
        value: data.types.length,
        unit: 'jenis alergi',
        icon: AppAssets.allergymonitoringIcon,
        color: const Color(0xFFFF777B),
      );
      final allergicStudentCard = _Metric(
        title: 'Siswa Alergi',
        value: data.allergicStudents,
        unit: 'siswa',
        icon: AppAssets.manstudentIcon,
        color: const Color(0xFFFFB58F),
      );

      if (useSingleColumn) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            allergyTypeCard,
            const SizedBox(height: 12),
            allergicStudentCard,
          ],
        );
      }

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: allergyTypeCard),
            const SizedBox(width: 12),
            Expanded(child: allergicStudentCard),
          ],
        ),
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
  final String icon;
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
        AppIcon(icon, size: 28),
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
