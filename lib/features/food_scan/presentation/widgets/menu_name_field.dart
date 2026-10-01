import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_icon.dart';

class MenuNameField extends StatelessWidget {
  const MenuNameField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextFormField(
    key: const Key('menu-name-field'),
    controller: controller,
    textInputAction: TextInputAction.next,
    decoration: const InputDecoration(
      labelText: 'Nama menu',
      hintText: 'Contoh: Nasi ayam kecap',
      prefixIcon: Padding(
        padding: EdgeInsets.all(12),
        child: AppIcon(AppAssets.scannermealIcon, size: 20),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    validator: (value) =>
        value == null || value.trim().isEmpty ? 'Nama menu wajib diisi' : null,
  );
}
