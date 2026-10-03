import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'widgets/profile_form_scaffold.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Mitra SPPG');
  final _emailController = TextEditingController(text: 'mitra@nutrisafe.id');
  final _phoneController = TextEditingController(text: '0812 3456 7890');
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProfileFormScaffold(
    title: 'Edit Profil',
    child: Form(
      key: _formKey,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              ),
              Material(
                color: AppColors.heading,
                shape: const CircleBorder(),
                child: IconButton(
                  key: const Key('change-profile-photo'),
                  tooltip: 'Ubah foto profil',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih foto profil dari perangkat.'),
                    ),
                  ),
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ProfileSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileField(label: 'Nama mitra', controller: _nameController),
                const SizedBox(height: 16),
                _ProfileField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _ProfileField(
                  label: 'Nomor telepon',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _ProfileField(
                  label: 'Alamat',
                  controller: _addressController,
                  maxLines: 3,
                  required: false,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('save-profile-button'),
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil berhasil disimpan.'),
                      ),
                    );
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.required = true,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool required;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) => required && (value?.trim().isEmpty ?? true)
            ? '$label wajib diisi.'
            : null,
      ),
    ],
  );
}
