import 'package:nutrisafe_mitra/core/constants/app_assets.dart';

import '../../../core/widgets/responsive_content.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrisafe_mitra/app/theme/app_colors.dart';

import '../data/auth_repository.dart';
import 'auth_cubit.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_form_card.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_link.dart';
import 'widgets/auth_account_prompt.dart';
import 'widgets/auth_password_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authCubit});

  final AuthCubit? authCubit;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  Future<void> _login() async {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await widget.authCubit?.login(
      email: _emailController.text,
      password: _passwordController.text,
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
    final authCubit = widget.authCubit;
    if (authCubit == null) {
      return _buildScaffold(context, const AuthActionState());
    }
    return BlocProvider.value(
      value: authCubit,
      child: BlocConsumer<AuthCubit, AuthActionState>(
        listener: (context, state) {
          if (state.status != AuthActionStatus.failure ||
              state.message == null) {
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        },
        builder: _buildScaffold,
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, AuthActionState authState) =>
      Scaffold(
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
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
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
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              errorMaxLines: 3,
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return 'Email wajib diisi.';
                              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch(email)) {
                                return 'Format email tidak valid.';
                              }
                              return isSppgEmail(email)
                                  ? null
                                  : 'Gunakan email dengan domain @sppg.id.';
                            },
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
                            validator: (value) => value == null || value.isEmpty
                                ? 'Password wajib diisi.'
                                : null,
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
                            label: authState.status == AuthActionStatus.loading
                                ? 'Memproses...'
                                : 'Masuk',
                            onPressed:
                                authState.status == AuthActionStatus.loading
                                ? null
                                : _login,
                          ),
                          const SizedBox(height: 16),

                          AuthAccountPrompt(
                            message: 'Ingin bergabung? ',
                            linkLabel: 'Daftar Jadi Mitra',
                            onTap: () => context.push('/register'),
                          ),
                        ],
                      ),
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
