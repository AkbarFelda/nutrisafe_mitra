import 'package:nutrisafe_mitra/core/constants/app_assets.dart';

import '../../../core/widgets/responsive_content.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrisafe_mitra/app/theme/app_colors.dart';

import 'session_cubit.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_form_card.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_link.dart';
import 'widgets/auth_account_prompt.dart';
import 'widgets/auth_password_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showUnavailablePage(String page) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Halaman $page belum tersedia.')));
  }

  Future<void> _login() async {
    if (!kDebugMode) {
      _showUnavailablePage('login');
      return;
    }

    await context.read<SessionCubit>().acceptAuthenticatedToken(
      'nutrisafe-local-debug-session',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 600,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const AuthHeader(),
                const SizedBox(height: 36),

                const Text(
                  'Masuk Akun',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 24),

                AuthFormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthFieldLabel(
                        text: 'Email',
                        icon: AppAssets.emailIcon,
                        color: AppColors.emailIcon,
                        spacing: 8,
                      ),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        autocorrect: false,
                        decoration: const InputDecoration(hintText: 'Email'),
                      ),
                      const SizedBox(height: 16),

                      const AuthFieldLabel(
                        text: 'Password',
                        icon: AppAssets.passwordIcon,
                        color: AppColors.passwordIcon,
                        spacing: 8,
                      ),
                      AuthPasswordField(
                        controller: _passwordController,
                        hintText: 'Password',
                        autofillHints: const [AutofillHints.password],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AuthTextLink(
                          label: 'Lupa password?',
                          onTap: () => context.push('/forgot-password'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      AuthPrimaryButton(
                        label: kDebugMode ? 'Masuk Mode Demo' : 'Masuk',
                        onPressed: _login,
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Mode debug: email dan password boleh dikosongkan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      AuthAccountPrompt(
                        message: 'Ingin bergabung? ',
                        linkLabel: 'Daftar Jadi Mitra',
                        onTap: () => context.push('/register'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
