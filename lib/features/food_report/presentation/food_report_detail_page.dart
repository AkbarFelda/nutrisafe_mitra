import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/responsive_content.dart';
import '../domain/food_report.dart';

class FoodReportDetailPage extends StatelessWidget {
  const FoodReportDetailPage({super.key, required this.report});

  final FoodReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      appBar: AppBar(
        backgroundColor: AppColors.loginBackground,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.heading),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Detail Riwayat Laporan ${report.school}',
            maxLines: 1,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SchoolInfoCard(report: report),
                const SizedBox(height: 14),
                _ReportMetrics(report: report),
                const SizedBox(height: 16),
                _MenuTableCard(report: report),
                const SizedBox(height: 16),
                _DocumentationCard(photos: report.documentationPhotos),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SchoolInfoCard extends StatelessWidget {
  const _SchoolInfoCard({required this.report});

  final FoodReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppIcon(AppAssets.schoolIcon, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.school,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.address,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF90CAF9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  foodReportDate(report.date),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D256C),
                  ),
                ),
              ),
              if (report.status case final status?)
                _ReportStatusBadge(status: status),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportMetrics extends StatelessWidget {
  const _ReportMetrics({required this.report});

  final FoodReport report;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final stacked = constraints.maxWidth < 360 * scale;
        final width = stacked
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: width,
              child: _MetricCard(
                title: 'Total Porsi',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _MetricValue(
                    value: '${report.portions}',
                    unit: 'Porsi',
                  ),
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                title: 'Terdistribusi',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _MetricValue(
                        value: report.distributedPortions?.toString() ?? '—',
                        unit: 'Porsi',
                      ),
                      Text(
                        report.distributionPercentage == null
                            ? 'Belum tersedia'
                            : '${report.distributionPercentage}% Selesai',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                title: 'Siswa Alergi',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _MetricValue(
                        value: report.studentsWithAllergies?.toString() ?? '—',
                        unit: 'Siswa',
                      ),
                      const SizedBox(height: 2),
                      for (final (index, allergy) in report.allergies.indexed)
                        _AllergyIndicator(
                          color: index.isEven ? Colors.red : Colors.amber,
                          label:
                              '${allergy.students} Siswa Alergi ${allergy.name}',
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AllergyIndicator extends StatelessWidget {
  const _AllergyIndicator({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 4.5,
            height: 4.5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 7.5, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTableCard extends StatelessWidget {
  const _MenuTableCard({required this.report});

  final FoodReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Menu Makanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Jumlah',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFFC7CBD1),
            child: const Text(
              'Nama Menu Makanan',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          ...report.menuItems.map((item) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item.category.isNotEmpty) ...[
                              const SizedBox(height: 1),
                              Text(
                                item.category,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          '${item.portions} Porsi',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 0.8,
                  color: Color(0xFFE0E0E0),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DocumentationCard extends StatelessWidget {
  const _DocumentationCard({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Foto Dokumentasi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          if (photos.isEmpty)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FB),
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 38,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada foto dokumentasi',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (final (index, photo) in photos.indexed) ...[
                  if (index > 0) const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.asset(
                        photo,
                        width: double.infinity,
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 42,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({required this.value, required this.unit});

  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Flexible(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(width: 3),
      Flexible(
        child: Text(
          unit,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10),
        ),
      ),
    ],
  );
}

class _ReportStatusBadge extends StatelessWidget {
  const _ReportStatusBadge({required this.status});

  final FoodReportStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon, foreground, background) = switch (status) {
      FoodReportStatus.received => (
        'Diterima',
        Icons.check,
        const Color(0xFF2E7D32),
        const Color(0xFFC8E6C9),
      ),
      FoodReportStatus.pending => (
        'Menunggu',
        Icons.schedule,
        const Color(0xFF8D6E00),
        const Color(0xFFFFF3CD),
      ),
      FoodReportStatus.rejected => (
        'Ditolak',
        Icons.close,
        const Color(0xFFC62828),
        const Color(0xFFFFCDD2),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
