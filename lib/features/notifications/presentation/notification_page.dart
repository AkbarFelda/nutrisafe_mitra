import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/error/app_failure.dart';
import '../data/notification_repository.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key, this.repository});
  final NotificationRepository? repository;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<AppNotification> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = widget.repository;
    if (repository == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await repository.getNotifications();
      if (mounted) setState(() => _items = result.items);
    } catch (error) {
      if (mounted) setState(() => _error = AppFailure.from(error).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markOne(AppNotification item) async {
    if (item.isRead || widget.repository == null) return;
    try {
      await widget.repository!.markAsRead(item.id);
      if (!mounted) return;
      setState(() => _items = [
        for (final current in _items)
          current.id == item.id ? current.copyWith(isRead: true) : current,
      ]);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppFailure.from(error).message)));
    }
  }

  Future<void> _markAll() async {
    if (widget.repository == null || !_items.any((item) => !item.isRead)) return;
    try {
      await widget.repository!.markAllAsRead();
      if (mounted) setState(() => _items = _items.map((item) => item.copyWith(isRead: true)).toList());
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppFailure.from(error).message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((item) => !item.isRead).length;
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(unread == 0 ? 'Notifikasi' : 'Notifikasi ($unread)'),
        backgroundColor: AppColors.loginBackground,
        foregroundColor: AppColors.heading,
        elevation: 0,
        actions: [
          if (unread > 0) TextButton(onPressed: _markAll, child: const Text('Baca semua')),
        ],
      ),
      body: RefreshIndicator(onRefresh: _load, child: _body()),
    );
  }

  Widget _body() {
    if (_loading) return ListView(children: const [SizedBox(height: 260), Center(child: CircularProgressIndicator())]);
    if (_error != null) {
      return ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 140),
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Center(child: FilledButton(onPressed: _load, child: const Text('Coba lagi'))),
      ]);
    }
    if (_items.isEmpty) {
      return ListView(key: const Key('notification-list'), padding: const EdgeInsets.all(24), children: const [
        SizedBox(height: 130),
        Icon(Icons.notifications_none_rounded, size: 62, color: AppColors.primary),
        SizedBox(height: 14),
        Text('Belum ada notifikasi', textAlign: TextAlign.center),
      ]);
    }
    return ListView.separated(
      key: const Key('notification-list'),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _NotificationCard(item: _items[index], onTap: () => _markOne(_items[index])),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});
  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: !item.isRead ? Border.all(color: AppColors.primary.withValues(alpha: 0.18)) : null,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.loginBackground, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.notifications_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
              if (!item.isRead) const CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
            ]),
            const SizedBox(height: 5),
            Text(item.body, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.45)),
            const SizedBox(height: 8),
            Text(item.timeLabel.isNotEmpty ? item.timeLabel : _formatDate(item.createdAt), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ])),
        ]),
      ),
    ),
  );
}

String _formatDate(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
