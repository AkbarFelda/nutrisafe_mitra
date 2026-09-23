import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.leading, this.bannerHeight = 170});
  final Widget? leading;
  final double bannerHeight;
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
          const Flexible(
            child: Text(
              'NutriSafe MBG',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: bannerHeight,
        child: Image.asset(AppAssets.bannerlogin, fit: BoxFit.cover),
      ),
    ],
  );
}
