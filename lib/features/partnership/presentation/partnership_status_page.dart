import '../../../core/widgets/responsive_content.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

import 'sppg_registration_page.dart';
import 'widgets/partnership_app_bar.dart';
import 'widgets/partnership_summary_card.dart';
import 'widgets/sppg_card.dart';
import 'widgets/partnership_registration_button.dart';

class PartnershipStatusPage extends StatelessWidget {
  const PartnershipStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      appBar: const PartnershipAppBar(title: 'Status Kemitraan'),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          maxWidth: 720,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 190,
                        child: Image.asset(
                          AppAssets.bannerpartner,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 16),
                      const PartnershipSummaryCard(),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Daftar SPPG',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.apartment,
                              size: 18,
                              color: Colors.blueGrey,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      SppgCard(
                        onDetail: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Detail SPPG belum tersedia.'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              PartnershipRegistrationButton(
                onPressed: () {
                  final router = GoRouter.maybeOf(context);
                  if (router != null) {
                    router.push('/partnership/register');
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SppgRegistrationPage(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
