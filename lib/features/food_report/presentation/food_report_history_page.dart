import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/responsive_content.dart';
import '../data/sample_food_reports.dart';
import '../domain/food_report.dart';
import 'widgets/food_report_card.dart';
import '../../partnership/data/sppg_dashboard_repository.dart';
import 'food_report_detail_page.dart';

class FoodReportHistoryPage extends StatefulWidget {
  const FoodReportHistoryPage({super.key, this.reports, this.repository});

  final List<FoodReport>? reports;
  final SppgDashboardRepository? repository;

  @override
  State<FoodReportHistoryPage> createState() => _FoodReportHistoryPageState();
}

class _FoodReportHistoryPageState extends State<FoodReportHistoryPage> {
  late int _selectedMonth;
  Future<List<FoodReport>>? _futureReports;
  List<FoodReport> get _reports => widget.reports ?? sampleFoodReports;

  @override
  void initState() {
    super.initState();
    final providedReports = widget.reports;
    _selectedMonth = providedReports != null && providedReports.isNotEmpty
        ? providedReports.first.date.month
        : DateTime.now().month;
    _loadReports();
  }

  void _loadReports() {
    final repository = widget.repository;
    if (repository != null) {
      _futureReports = repository.getDeliveryReports(
        month: _selectedMonth,
        year: DateTime.now().year,
      );
    }
  }

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

  Future<void> _openDetail(FoodReport report) async {
    var detail = report;
    final id = report.id;
    if (widget.repository != null && id != null && id > 0) {
      try {
        detail = await widget.repository!.getDeliveryReportDetail(id);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detail pengiriman belum dapat dimuat.')),
        );
        return;
      }
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FoodReportDetailPage(report: detail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final future = _futureReports;
    if (future == null) return _buildPage(_reports);
    return FutureBuilder<List<FoodReport>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _loadingPage();
        }
        if (snapshot.hasError) {
          return _errorPage(snapshot.error!);
        }
        return _buildPage(snapshot.data ?? const []);
      },
    );
  }

  Widget _loadingPage() => Scaffold(
    backgroundColor: AppColors.loginBackground,
    appBar: _appBar(),
    body: const Center(child: CircularProgressIndicator()),
  );

  Widget _errorPage(Object error) => Scaffold(
    backgroundColor: AppColors.loginBackground,
    appBar: _appBar(),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Riwayat pengiriman belum dapat dimuat.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(_loadReports),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    ),
  );

  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: AppColors.loginBackground,
    scrolledUnderElevation: 0,
    leading: IconButton(
      tooltip: 'Kembali',
      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.heading),
      onPressed: _handleBack,
    ),
    title: const Text(
      'Riwayat Pengiriman',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );

  Widget _buildPage(List<FoodReport> allReports) {
    final reports =
        allReports
            .where((report) => report.date.month == _selectedMonth)
            .toList()
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
      appBar: _appBar(),
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
                              setState(() {
                                _selectedMonth = value;
                                _loadReports();
                              });
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
                              allReports.isEmpty
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
                              allReports.isEmpty
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
                                FoodReportCard(
                                  report: report,
                                  onTap: () => _openDetail(report),
                                ),
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
