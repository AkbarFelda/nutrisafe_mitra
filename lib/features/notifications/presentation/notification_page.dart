import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_icon.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const _items = [
    _NotificationItem(
      icon: AppAssets.recentreportIcon,
      title: 'Laporan berhasil dikirim',
      message: 'Laporan menu makanan hari ini telah tersimpan.',
      time: '10 menit lalu',
      unread: true,
    ),
    _NotificationItem(
      icon: AppAssets.handshakeIcon,
      title: 'Status kemitraan diperbarui',
      message: 'Dokumen pendaftaran SPPG sedang dalam proses verifikasi.',
      time: 'Kemarin',
      unread: true,
    ),
    _NotificationItem(
      icon: AppAssets.personwarningIcon,
      title: 'Tindak lanjut diperlukan',
      message: 'Ada laporan makanan bermasalah yang perlu ditinjau.',
      time: '2 hari lalu',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7FAFC),
    appBar: AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const Text('Notifikasi'),
      backgroundColor: AppColors.loginBackground,
      foregroundColor: AppColors.heading,
      elevation: 0,
    ),
    body: ListView.separated(
      key: const Key('notification-list'),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _NotificationCard(item: _items[index]),
    ),
  );
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});
  final _NotificationItem item;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: item.unread
          ? Border.all(color: AppColors.primary.withValues(alpha: 0.18))
          : null,
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.loginBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: AppIcon(item.icon, size: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (item.unread)
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: AppColors.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.message,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.unread,
  });

  final String icon;
  final String title;
  final String message;
  final String time;
  final bool unread;
}
