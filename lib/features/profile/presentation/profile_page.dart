import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_icon.dart';
import '../../auth/presentation/session_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7FAFC),
    appBar: AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const Text('Profil'),
      backgroundColor: AppColors.loginBackground,
      foregroundColor: AppColors.heading,
      elevation: 0,
    ),
    body: ListView(
      key: const Key('profile-scroll-view'),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        const _ProfileHeader(),
        const SizedBox(height: 28),
        const _ProfileMenuTile(
          icon: AppIcon(AppAssets.buildingIcon, size: 24),
          title: 'Data Mitra / SPPG',
          subtitle: 'Kelola informasi lembaga dan penanggung jawab',
        ),
        const SizedBox(height: 12),
        const _ProfileMenuTile(
          icon: AppIcon(AppAssets.passwordIcon, size: 24),
          title: 'Keamanan Akun',
          subtitle: 'Atur kata sandi dan keamanan akun',
        ),
        const SizedBox(height: 12),
        const _ProfileMenuTile(
          icon: Icon(Icons.help_outline_rounded),
          title: 'Pusat Bantuan',
          subtitle: 'Temukan jawaban atau hubungi tim NutriSafe',
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          key: const Key('profile-logout-button'),
          onPressed: () => context.read<SessionCubit>().logout(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Keluar dari akun'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: AppIcon(AppAssets.userIcon, size: 52, color: Colors.white),
        ),
      ),
      const SizedBox(height: 14),
      Text(
        'Mitra SPPG',
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      Text(
        'Pengelola Program Makan Bergizi Gratis',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: AppColors.textSecondary),
      ),
    ],
  );
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Widget icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.loginBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconTheme(
                data: const IconThemeData(color: AppColors.primary),
                child: Center(child: icon),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    ),
  );
}
