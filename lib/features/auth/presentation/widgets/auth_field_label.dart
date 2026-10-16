import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    this.spacing = 6,
  });
  final String text;
  final String icon;
  final Color color;
  final double spacing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: spacing),
    child: Row(
      children: [
        AppIcon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    ),
  );
}
