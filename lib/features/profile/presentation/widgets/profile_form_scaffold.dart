import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';

class ProfileFormScaffold extends StatelessWidget {
  const ProfileFormScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7FAFC),
    appBar: AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: AppColors.loginBackground,
      foregroundColor: AppColors.heading,
      elevation: 0,
    ),
    body: SafeArea(
      top: false,
      child: ResponsiveContent(
        maxWidth: 720,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              constraints.maxWidth < 400 ? 16 : 28,
              24,
              constraints.maxWidth < 400 ? 16 : 28,
              36,
            ),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: child,
    ),
  );
}
