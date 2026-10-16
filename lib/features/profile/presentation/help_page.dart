import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'widgets/profile_form_scaffold.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) => ProfileFormScaffold(
    title: 'Butuh Bantuan?',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.support_agent_rounded,
          size: 76,
          color: AppColors.primary,
        ),
        const SizedBox(height: 14),
        Text(
          'Ada yang bisa kami bantu?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: AppColors.heading, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Panduan singkat untuk menggunakan aplikasi NutriSafe Mitra.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        const ProfileSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HelpSection(
                title: 'Memperbarui data SPPG',
                description:
                    'Buka menu Profil, pilih Edit Profil, lalu perbarui informasi yang diperlukan. Periksa kembali data sebelum menekan tombol Simpan Perubahan.',
              ),
              SizedBox(height: 22),
              _HelpSection(
                title: 'Menghubungkan sekolah',
                description:
                    'Buka Daftar Sekolah dan pilih tab Tersedia. Tandai sekolah yang ingin dihubungkan, kemudian tekan Hubungkan. Sekolah yang berhasil ditambahkan akan muncul pada tab Terhubung.',
              ),
              SizedBox(height: 22),
              _HelpSection(
                title: 'Laporan belum tampil',
                description:
                    'Pastikan perangkat terhubung ke internet, kemudian buka kembali halaman terkait untuk memuat data terbaru.',
              ),
              SizedBox(height: 22),
              _HelpSection(
                title: 'Menjaga keamanan akun',
                description:
                    'Gunakan kata sandi yang unik, jangan membagikan kode OTP kepada siapa pun, dan selalu keluar dari akun ketika menggunakan perangkat bersama.',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.heading,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 7),
      Text(
        description,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.55,
        ),
      ),
    ],
  );
}
