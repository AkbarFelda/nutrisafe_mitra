import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/food_issue.dart';
import 'food_issue_section.dart';

class FoodIssueEvidence extends StatelessWidget {
  const FoodIssueEvidence({super.key, required this.report});
  final FoodIssue report;
  @override
  Widget build(BuildContext context) => FoodIssueSection(
    title: 'Bukti Foto',
    child: report.photoUrls.isEmpty
        ? const SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 12),
                  Text('Belum ada bukti foto', textAlign: TextAlign.center),
                ],
              ),
            ),
          )
        : Column(
            children: [
              for (final (index, url) in report.photoUrls.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Semantics(
                    button: true,
                    label: 'Perbesar bukti foto ${index + 1}',
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => Scaffold(
                            backgroundColor: Colors.black,
                            appBar: AppBar(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              title: Text('Bukti Foto ${index + 1}'),
                            ),
                            body: Center(
                              child: InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 5,
                                child: _photo(url, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: _photo(url),
                        ),
                      ),
                    ),
                  ),
                ),
              const Text(
                'Ketuk foto untuk memperbesar',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
  );
  Widget _photo(String url, {BoxFit fit = BoxFit.cover}) => Image.network(
    url,
    fit: fit,
    errorBuilder: (_, error, stackTrace) => const Center(
      child: Text(
        'Foto tidak dapat dimuat',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    ),
  );
}
