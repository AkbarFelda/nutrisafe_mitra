import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

import 'package:go_router/go_router.dart';

class PartnershipAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PartnershipAppBar({
    super.key,
    required this.title,
    this.fallbackRoute = '/',
  });
  final String title;
  final String fallbackRoute;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: AppColors.loginBackground,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    automaticallyImplyLeading: false,

    leading: IconButton(
      tooltip: 'Kembali',
      icon: const Icon(
        Icons.arrow_back_ios_new,
        color: AppColors.heading,
        size: 20,
      ),
      onPressed: () {
        final router = GoRouter.maybeOf(context);

        if (router != null) {
          if (router.canPop()) {
            router.pop();
          } else {
            router.go(fallbackRoute);
          }
        } else {
          Navigator.maybePop(context);
        }
      },
    ),

    titleSpacing: 0,
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.heading,
      ),
    ),
  );
}
