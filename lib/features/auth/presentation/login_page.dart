import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Masuk Mitra/SPPG')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Layanan masuk belum tersedia. Silakan coba lagi nanti.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
