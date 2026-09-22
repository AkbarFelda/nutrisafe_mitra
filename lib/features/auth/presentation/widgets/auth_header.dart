import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.leading});
  final Widget? leading;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leading ??
              Image.asset(
                AppAssets.logo,
                width: 35,
                height: 35,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
          const SizedBox(width: 8),
          const Text(
            'NutriSafe MBG',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 170,
        child: Image.asset(AppAssets.bannerlogin, fit: BoxFit.cover),
      ),
    ],
  );
}
