import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/presentation/api_cubit.dart';
import '../../../core/widgets/responsive_content.dart';
import '../data/password_repository.dart';
import 'widgets/auth_password_field.dart';
import 'widgets/auth_primary_button.dart';

enum _ResetStep { email, otp, password, success }

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.repository});

  final PasswordRepository? repository;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _apiCubit = ApiCubit<void>();
  _ResetStep _step = _ResetStep.email;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _apiCubit.close();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_step == _ResetStep.otp &&
        _otpControllers.any((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kode OTP 6 digit.')),
      );
      return;
    }
    if (_step == _ResetStep.email && widget.repository != null) {
      final success = await _apiCubit.run(
        () => widget.repository!.requestResetCode(_emailController.text.trim()),
      );
      if (!success || !mounted) return;
    }
    if (_step == _ResetStep.password && widget.repository != null) {
      final success = await _apiCubit.run(
        () => widget.repository!.resetPassword(
          email: _emailController.text.trim(),
          code: _otpControllers.map((controller) => controller.text).join(),
          newPassword: _passwordController.text,
        ),
      );
      if (!success || !mounted) return;
    }
    setState(() => _step = _ResetStep.values[_step.index + 1]);
  }

  String get _title => switch (_step) {
    _ResetStep.email => 'Lupa Kata Sandi',
    _ResetStep.otp => 'Verifikasi Kode',
    _ResetStep.password => 'Buat Kata Sandi Baru',
    _ResetStep.success => 'Kata Sandi Berhasil Diubah',
  };

  String get _description => switch (_step) {
    _ResetStep.email =>
      'Masukkan email yang terdaftar. Kami akan mengirimkan kode verifikasi.',
    _ResetStep.otp =>
      'Masukkan 6 digit kode yang telah dikirim ke ${_emailController.text}.',
    _ResetStep.password =>
      'Gunakan kata sandi yang kuat dan belum pernah digunakan sebelumnya.',
    _ResetStep.success =>
      'Silakan masuk kembali menggunakan kata sandi baru Anda.',
  };

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _apiCubit,
    child: BlocListener<ApiCubit<void>, ApiState<void>>(
      listener: (context, state) {
        if (state.status == ApiStatus.failure && state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.loginBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.heading,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Kembali',
            onPressed: () {
              if (_step == _ResetStep.email) {
                context.pop();
              } else {
                setState(() => _step = _ResetStep.values[_step.index - 1]);
              }
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SafeArea(
          top: false,
          child: ResponsiveContent(
            maxWidth: 560,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth < 400 ? 18.0 : 32.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          _step == _ResetStep.success
                              ? Icons.check_circle_rounded
                              : Icons.lock_reset_rounded,
                          size: constraints.maxWidth < 360 ? 68 : 84,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.heading,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 28),
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              constraints.maxWidth < 360 ? 18 : 24,
                            ),
                            child: _buildStep(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildStep() => switch (_step) {
    _ResetStep.email => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          key: const Key('forgot-email-field'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            hintText: 'nama@email.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            final email = value?.trim() ?? '';
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
              return 'Masukkan alamat email yang valid.';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        BlocBuilder<ApiCubit<void>, ApiState<void>>(
          builder: (context, state) => AuthPrimaryButton(
            label: state.status == ApiStatus.loading
                ? 'Mengirim...'
                : 'Kirim Kode',
            onPressed: state.status == ApiStatus.loading ? null : _submit,
          ),
        ),
      ],
    ),
    _ResetStep.otp => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: 44,
                  child: TextFormField(
                    key: Key('otp-field-$index'),
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _otpFocusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _otpFocusNodes[index - 1].requestFocus();
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(label: 'Verifikasi', onPressed: _submit),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () async {
            final repository = widget.repository;
            if (repository == null) return;
            final success = await _apiCubit.run(
              () => repository.requestResetCode(_emailController.text.trim()),
            );
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kode verifikasi dikirim ulang.')),
              );
            }
          },
          child: const Text('Kirim ulang kode'),
        ),
      ],
    ),
    _ResetStep.password => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Kata sandi baru',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        AuthPasswordField(
          controller: _passwordController,
          hintText: 'Minimal 8 karakter',
        ),
        const SizedBox(height: 16),
        const Text(
          'Konfirmasi kata sandi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        AuthPasswordField(
          controller: _confirmationController,
          hintText: 'Ulangi kata sandi baru',
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          label: 'Simpan Kata Sandi',
          onPressed: () {
            if (_passwordController.text.length < 8) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kata sandi minimal 8 karakter.')),
              );
              return;
            }
            if (_passwordController.text != _confirmationController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Konfirmasi kata sandi tidak cocok.'),
                ),
              );
              return;
            }
            _submit();
          },
        ),
      ],
    ),
    _ResetStep.success => AuthPrimaryButton(
      label: 'Kembali ke Halaman Masuk',
      onPressed: () => context.go('/login'),
    ),
  };
}
