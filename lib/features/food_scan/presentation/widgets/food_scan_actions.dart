import 'package:flutter/material.dart';

class AnalyzeFoodButton extends StatelessWidget {
  const AnalyzeFoodButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    key: const Key('analyze-food'),
    onPressed: isLoading ? null : onPressed,
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(54),
      backgroundColor: const Color(0xFF16A34A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    icon: isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Icon(Icons.auto_awesome_rounded),
    label: Text(isLoading ? 'Menganalisis...' : 'Mulai Analisis'),
  );
}

class SubmitFoodReportButton extends StatelessWidget {
  const SubmitFoodReportButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    key: const Key('submit-food-report'),
    onPressed: isLoading ? null : onPressed,
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    icon: isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.send_outlined),
    label: Text(isLoading ? 'Mengirim...' : 'Kirim Laporan Menu'),
  );
}
