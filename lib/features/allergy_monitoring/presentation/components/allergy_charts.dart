import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;

import '../../domain/allergy_monitoring.dart';

Color allergyColor(StudentAllergy type) => switch (type) {
  StudentAllergy.peanut => const Color(0xFFD90000),
  StudentAllergy.egg => const Color(0xFFFFCC26),
  StudentAllergy.milk => const Color(0xFFD600D9),
};

class AllergyPieChart extends StatelessWidget {
  const AllergyPieChart({super.key, required this.data});
  final AllergyMonitoringData data;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (data.totalAllergies == 0)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Belum ada data alergi siswa'),
        )
      else
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                label:
                    'Diagram proporsi jenis alergi. Rincian tersedia di bawah.',
                image: true,
                child: CustomPaint(
                  painter: _PiePainter([
                    for (final type in StudentAllergy.values) data.count(type),
                  ]),
                ),
              ),
            ),
          ),
        ),
      const SizedBox(height: 20),
      for (final type in StudentAllergy.values)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.circle, size: 13, color: allergyColor(type)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(type.label, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text(
                allergyPercentage(
                  data.totalAllergies == 0
                      ? 0
                      : data.count(type) / data.totalAllergies,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.counts);
  final List<int> counts;
  @override
  void paint(Canvas canvas, Size size) {
    final total = counts.fold(0, (a, b) => a + b);
    if (total == 0) return;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: math.min(size.width, size.height) / 2 - 4,
    );
    var angle = -math.pi;
    for (var i = 0; i < counts.length; i++) {
      final sweep = counts[i] / total * math.pi * 2;
      canvas.drawArc(
        rect,
        angle,
        sweep,
        true,
        Paint()..color = allergyColor(StudentAllergy.values[i]),
      );
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter oldDelegate) =>
      !listEquals(oldDelegate.counts, counts);
}

class AllergyBarChart extends StatelessWidget {
  const AllergyBarChart({super.key, required this.data});
  final AllergyMonitoringData data;
  @override
  Widget build(BuildContext context) {
    final counts = [for (final type in StudentAllergy.values) data.count(type)];
    final largest = counts.fold(0, math.max);
    final step = math.max(1, (largest / 4).ceil());
    final maxValue = step * 4;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 4; i >= 0; i--)
                      Text('${step * i}', style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var i = 0; i < 5; i++)
                            const Divider(height: 1, color: Color(0xFFDDDDDD)),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final type in StudentAllergy.values)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: FractionallySizedBox(
                                  heightFactor: data.count(type) / maxValue,
                                  alignment: Alignment.bottomCenter,
                                  child: ColoredBox(
                                    color: allergyColor(type),
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final type in StudentAllergy.values)
                Expanded(
                  child: Text(
                    type.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (final type in StudentAllergy.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.circle, size: 10, color: allergyColor(type)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${data.count(type)} siswa ${type.label.toLowerCase()}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
