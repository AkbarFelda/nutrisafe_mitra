import 'package:flutter/material.dart';

import '../../auth/presentation/widgets/auth_password_field.dart';
import 'widgets/profile_form_scaffold.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _save() {
    if (_currentController.text.isEmpty) {
      _showMessage('Masukkan kata sandi saat ini.');
    } else if (_newController.text.length < 8) {
      _showMessage('Kata sandi baru minimal 8 karakter.');
    } else if (_newController.text != _confirmationController.text) {
      _showMessage('Konfirmasi kata sandi baru tidak cocok.');
    } else {
      _showMessage('Kata sandi berhasil diperbarui.');
      _currentController.clear();
      _newController.clear();
      _confirmationController.clear();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => ProfileFormScaffold(
    title: 'Ubah Kata Sandi',
    child: ProfileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Kata sandi saat ini', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          AuthPasswordField(controller: _currentController, hintText: 'Masukkan kata sandi saat ini'),
          const SizedBox(height: 18),
          const Text('Kata sandi baru', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          AuthPasswordField(controller: _newController, hintText: 'Minimal 8 karakter'),
          const SizedBox(height: 18),
          const Text('Konfirmasi kata sandi baru', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          AuthPasswordField(controller: _confirmationController, hintText: 'Ulangi kata sandi baru'),
          const SizedBox(height: 10),
          const Text('Gunakan kombinasi huruf, angka, dan simbol agar akun lebih aman.', style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('change-password-button'),
            onPressed: _save,
            child: const Text('Perbarui Kata Sandi'),
          ),
        ],
      ),
    ),
  );
}
