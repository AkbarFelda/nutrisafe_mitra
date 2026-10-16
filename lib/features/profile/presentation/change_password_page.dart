import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/api_cubit.dart';
import '../../auth/data/password_repository.dart';
import '../../auth/presentation/session_cubit.dart';
import '../../auth/presentation/widgets/auth_password_field.dart';
import 'widgets/profile_form_scaffold.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, this.repository, this.session});

  final PasswordRepository? repository;
  final SessionCubit? session;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _apiCubit = ApiCubit<void>();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmationController.dispose();
    _apiCubit.close();
    super.dispose();
  }

  Future<void> _save() async {
    if (_currentController.text.isEmpty) {
      _showMessage('Masukkan kata sandi saat ini.');
    } else if (_newController.text.length < 8) {
      _showMessage('Kata sandi baru minimal 8 karakter.');
    } else if (_newController.text != _confirmationController.text) {
      _showMessage('Konfirmasi kata sandi baru tidak cocok.');
    } else {
      final repository = widget.repository;
      if (repository == null) return;
      final success = await _apiCubit.run(
        () => repository.changePassword(
          oldPassword: _currentController.text,
          newPassword: _newController.text,
        ),
      );
      if (!success || !mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.green,
            size: 52,
          ),
          title: const Text('Kata Sandi Berhasil Diubah'),
          content: const Text(
            'Silakan login kembali menggunakan kata sandi baru.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              key: const Key('change-password-success-ok'),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      await widget.session?.logout();
      if (mounted) context.go('/login');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _apiCubit,
    child: BlocListener<ApiCubit<void>, ApiState<void>>(
      listener: (context, state) {
        if (state.status == ApiStatus.failure && state.message != null) {
          _showMessage(state.message!);
        }
      },
      child: ProfileFormScaffold(
        title: 'Ubah Kata Sandi',
        child: ProfileSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kata sandi saat ini',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AuthPasswordField(
                controller: _currentController,
                hintText: 'Masukkan kata sandi saat ini',
              ),
              const SizedBox(height: 18),
              const Text(
                'Kata sandi baru',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AuthPasswordField(
                controller: _newController,
                hintText: 'Minimal 8 karakter',
              ),
              const SizedBox(height: 18),
              const Text(
                'Konfirmasi kata sandi baru',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AuthPasswordField(
                controller: _confirmationController,
                hintText: 'Ulangi kata sandi baru',
              ),
              const SizedBox(height: 10),
              const Text(
                'Gunakan kombinasi huruf, angka, dan simbol agar akun lebih aman.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              BlocBuilder<ApiCubit<void>, ApiState<void>>(
                builder: (context, state) => FilledButton(
                  key: const Key('change-password-button'),
                  onPressed: state.status == ApiStatus.loading ? null : _save,
                  child: Text(
                    state.status == ApiStatus.loading
                        ? 'Memproses...'
                        : 'Perbarui Kata Sandi',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
