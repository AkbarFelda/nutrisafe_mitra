import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'auth_text_link.dart';

class AuthAccountPrompt extends StatelessWidget {
  const AuthAccountPrompt({
    super.key,
    required this.message,
    required this.linkLabel,
    required this.onTap,
  });
  final String message;
  final String linkLabel;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Center(
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          message,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        AuthTextLink(label: linkLabel, onTap: onTap),
      ],
    ),
  );
}
