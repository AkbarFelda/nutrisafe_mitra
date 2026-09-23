import 'package:flutter/material.dart';

class SppgCard extends StatelessWidget {
  const SppgCard({super.key, required this.onDetail});
  final VoidCallback onDetail;
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
          // Icon SPPG
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.domain_verification,
              color: Color(0xFF007AFF),
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          // Detail SPPG
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPPG Indonesia',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Status: Aktif',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
                Text(
                  'Alamat: Jl. Indonesia',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
                Text(
                  'Kapasitas: 100 Porsi',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Tombol Detail
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
