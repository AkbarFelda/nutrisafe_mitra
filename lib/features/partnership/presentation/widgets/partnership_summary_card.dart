import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class PartnershipSummaryCard extends StatelessWidget {
  const PartnershipSummaryCard({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Text(
            'Status Kemitraan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
            ),
          ),

          SizedBox(height: 8),

          // Status aktif
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatusCheckIcon(),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Anda telah menjadi mitra SPPG!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Summary SPPG & Sekolah
          _SummaryCounts(),
        ],
      ),
    ),
  );
}

class _StatusCheckIcon extends StatelessWidget {
  const _StatusCheckIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Color(0xFF00C853),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 14),
    );
  }
}

// ============================================================
// SUMMARY COUNTS
// ============================================================

class _SummaryCounts extends StatelessWidget {
  const _SummaryCounts();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(11) > 16;
        final width = stacked
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: width,
              child: const _CountBadge(
                label: 'Daftar SPPG',
                count: '1',
                icon: Icons.apartment,
                color: Color(0xFFFF7A22),
              ),
            ),
            SizedBox(
              width: width,
              child: const _CountBadge(
                label: 'Daftar Sekolah',
                count: '2',
                icon: Icons.school_outlined,
                color: AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// COUNT BADGE
// ============================================================

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final String count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
