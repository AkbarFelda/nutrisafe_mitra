import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _partnerMenus = [
    _HomeMenu(
      label: 'Status Kemitraan\n& Daftar SPPG',
      icon: Icons.handshake_outlined,
      route: '/partnership/status',
    ),
    _HomeMenu(
      label: 'Riwayat Laporan',
      icon: Icons.assignment_outlined,
      route: '/food-reports/history',
    ),
  ];

  static const _managerMenus = [
    _HomeMenu(
      label: 'Monitoring Alergi\nSiswa',
      icon: Icons.monitor_heart_outlined,
      route: '/students/allergies',
    ),
    _HomeMenu(
      label: 'Scan & Pelaporan\nMenu Makanan',
      icon: Icons.document_scanner_outlined,
      route: '/food-reports/scan',
    ),
    _HomeMenu(
      label: 'Daftar Sekolah',
      icon: Icons.school_outlined,
      route: '/schools',
    ),
    _HomeMenu(
      label: 'Laporan Makanan\nBermasalah',
      icon: Icons.assignment_late_outlined,
      route: '/food-reports/issues',
    ),
  ];

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.dashboardBackground,
    child: SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const Key('home-scroll-view'),
        slivers: [
          const SliverToBoxAdapter(child: _HomeHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
            sliver: SliverList.list(
              children: [
                const _SectionTitle('Menu Mitra'),
                const SizedBox(height: 8),
                _MenuGrid(items: _partnerMenus),
                const SizedBox(height: 16),
                const _SectionTitle('Menu Pengelola'),
                const SizedBox(height: 8),
                _MenuGrid(items: _managerMenus),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.logo, width: 38, height: 38),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Dashboard Mitra & Pengelola',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: double.infinity,
        height: 190,
        child: Image.asset(AppAssets.bannerpartner, fit: BoxFit.cover),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.items});
  final List<_HomeMenu> items;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 18,
      mainAxisSpacing: 10,
      childAspectRatio: 1.22,
    ),
    itemBuilder: (context, index) => _MenuCard(menu: items[index]),
  );
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.menu});
  final _HomeMenu menu;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.dashboardTile,
    borderRadius: BorderRadius.circular(6),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: Key('home-menu-${menu.route}'),
      onTap: () => context.push(menu.route),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(menu.icon, color: Colors.white, size: 42),
            const SizedBox(height: 10),
            Text(
              menu.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HomeMenu {
  const _HomeMenu({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
