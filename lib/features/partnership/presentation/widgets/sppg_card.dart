import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../data/sppg_dashboard_repository.dart';

class SppgCard extends StatelessWidget {
  const SppgCard({super.key, required this.onDetail, this.status});
  final VoidCallback onDetail;
  final SppgStatus? status;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: AppIcon(AppAssets.buildingIcon, size: 28),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status?.name ?? 'SPPG Indonesia',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${status?.status ?? 'Aktif'}',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
                Text(
                  'Alamat: ${status?.address ?? 'Jl. Indonesia'}',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
                Text(
                  'Kapasitas: ${status?.capacity ?? 100} Porsi',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E74D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Detail',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
