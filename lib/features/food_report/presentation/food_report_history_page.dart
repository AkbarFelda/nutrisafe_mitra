import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/responsive_content.dart';
import '../data/sample_food_reports.dart';
import '../domain/food_report.dart';
import 'widgets/food_report_card.dart';

class FoodReportHistoryPage extends StatefulWidget {
  const FoodReportHistoryPage({super.key, this.reports});

  final List<FoodReport>? reports;

  @override
  State<FoodReportHistoryPage> createState() => _FoodReportHistoryPageState();
}

class _FoodReportHistoryPageState extends State<FoodReportHistoryPage> {
  int _selectedMonth = 3;

  List<FoodReport> get _reports => widget.reports ?? sampleFoodReports;

  void _handleBack() {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      Navigator.maybePop(context);
    } else if (router.canPop()) {
      router.pop();
    } else {
      router.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports =
        _reports.where((report) => report.date.month == _selectedMonth).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final groups = <DateTime, List<FoodReport>>{};
    for (final report in reports) {
      final day = DateTime(
        report.date.year,
        report.date.month,
        report.date.day,
      );
      groups.putIfAbsent(day, () => []).add(report);
    }
    final days = groups.keys.toList();
    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      appBar: AppBar(
        backgroundColor: AppColors.loginBackground,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.heading),
          onPressed: _handleBack,
        ),
        title: const Text(
          'Riwayat Laporan Makanan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.heading,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC2C7CC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMonth,
                          isDense: true,
                          itemHeight: null,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: Colors.white,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          dropdownColor: Colors.grey.shade700,
                          items: [
                            for (var month = 1; month <= 12; month++)
                              DropdownMenuItem(
                                value: month,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Text(foodReportMonths[month - 1]),
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedMonth = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (reports.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const AppIcon(AppAssets.recentreportIcon, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              _reports.isEmpty
                                  ? 'Belum ada laporan makanan'
                                  : 'Belum ada laporan bulan ini',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.heading,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _reports.isEmpty
                                  ? 'Laporan makanan yang telah dikirim akan muncul di sini.'
                                  : 'Silakan pilih bulan lain untuk melihat riwayat laporan.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                foodReportDate(day),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.heading,
                                ),
                              ),
                              for (final report in groups[day]!) ...[
                                const SizedBox(height: 8),
                                FoodReportCard(report: report),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
