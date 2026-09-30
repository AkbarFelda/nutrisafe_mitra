import 'package:flutter/material.dart';

class FoodScanIntroCard extends StatelessWidget {
  const FoodScanIntroCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0D75E8), Color(0xFF55B5F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x26007AFF),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cek menu hari ini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Foto menu dan dapatkan ringkasan gizinya dalam satu langkah.',
                style: TextStyle(
                  color: Color(0xFFEAF6FF),
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 14),
        Icon(Icons.auto_awesome, color: Colors.white, size: 38),
      ],
    ),
  );
}
