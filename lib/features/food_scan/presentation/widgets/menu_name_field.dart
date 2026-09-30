import 'package:flutter/material.dart';

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
      prefixIcon: Icon(Icons.restaurant_menu_rounded),
      filled: true,
      fillColor: Colors.white,
    ),
    validator: (value) =>
        value == null || value.trim().isEmpty ? 'Nama menu wajib diisi' : null,
  );
}
