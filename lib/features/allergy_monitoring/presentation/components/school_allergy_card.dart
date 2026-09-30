import 'package:flutter/material.dart';

import '../../domain/allergy_monitoring.dart';

class SchoolAllergyCard extends StatelessWidget {
  const SchoolAllergyCard({super.key, required this.school});
  final SchoolAllergyData school;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFBDF5FC),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.school_rounded,
              size: 34,
              color: Color(0xFFE59125),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      Text(
                        '${school.students} siswa',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${school.allergicStudents} siswa alergi',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF933019),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${allergyPercentage(school.allergyRate)} siswa alergi',
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: school.allergyRate.clamp(0.0, 1.0),
          minHeight: 6,
          borderRadius: BorderRadius.circular(10),
          backgroundColor: const Color(0xFFD0D0D0),
          color: const Color(0xFFFF6268),
          semanticsLabel: 'Persentase siswa alergi di ${school.name}',
        ),
      ],
    ),
  );
}
