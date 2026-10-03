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
        const Icon(Icons.support_agent_rounded, size: 76, color: AppColors.primary),
        const SizedBox(height: 14),
        Text(
          'Ada yang bisa kami bantu?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.heading,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Temukan jawaban cepat atau hubungi tim NutriSafe.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        ProfileSectionCard(
          child: Column(
            children: const [
              _ContactTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Chat WhatsApp',
                subtitle: 'Senin–Jumat, 08.00–17.00 WIB',
              ),
              Divider(height: 28),
              _ContactTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'support@nutrisafe.id',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Pertanyaan umum', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        const ProfileSectionCard(
          child: Column(
            children: [
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('Bagaimana cara memperbarui data SPPG?'),
                children: [Padding(padding: EdgeInsets.only(bottom: 16), child: Text('Buka Profil, pilih Data Mitra / SPPG, lalu perbarui informasi dan simpan perubahan.'))],
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('Mengapa laporan belum tampil?'),
                children: [Padding(padding: EdgeInsets.only(bottom: 16), child: Text('Pastikan perangkat terhubung ke internet, kemudian muat ulang halaman laporan.'))],
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('Bagaimana menjaga keamanan akun?'),
                children: [Padding(padding: EdgeInsets.only(bottom: 16), child: Text('Gunakan kata sandi unik, jangan membagikan kode OTP, dan keluar dari perangkat bersama.'))],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      backgroundColor: AppColors.loginBackground,
      child: Icon(icon, color: AppColors.primary),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membuka $title...')),
    ),
  );
}
