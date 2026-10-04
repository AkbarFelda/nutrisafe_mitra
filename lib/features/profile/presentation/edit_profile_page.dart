import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/api_cubit.dart';
import '../data/profile_repository.dart';
import '../data/sppg_profile.dart';
import 'widgets/profile_form_scaffold.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, this.repository});

  final ProfileRepository? repository;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _institutionController = TextEditingController();
  final _apiCubit = ApiCubit<SppgProfile>();

  @override
  void initState() {
    super.initState();
    final repository = widget.repository;
    if (repository != null) {
      _apiCubit.run(repository.getProfile).then((success) {
        final profile = _apiCubit.state.data;
        if (!success || !mounted || profile == null) return;
        _fill(profile);
      });
    }
  }

  void _fill(SppgProfile profile) {
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _addressController.text = profile.location;
    _institutionController.text = profile.institutionName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _institutionController.dispose();
    _apiCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _apiCubit,
    child: BlocListener<ApiCubit<SppgProfile>, ApiState<SppgProfile>>(
      listener: (context, state) {
        if (state.status == ApiStatus.failure && state.message != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message!)));
        } else if (state.status == ApiStatus.success && state.message != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      child: ProfileFormScaffold(
        title: 'Edit Profil',
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ProfileSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileField(
                      label: 'Nama mitra',
                      controller: _nameController,
                    ),
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
                    const SizedBox(height: 16),
                    _ProfileField(
                      label: 'Nama instansi',
                      controller: _institutionController,
                      required: false,
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<ApiCubit<SppgProfile>, ApiState<SppgProfile>>(
                      builder: (context, state) => FilledButton(
                        key: const Key('save-profile-button'),
                        onPressed: state.status == ApiStatus.loading
                            ? null
                            : () {
                                if (!(_formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                                final repository = widget.repository;
                                if (repository == null) return;
                                _apiCubit.run(
                                  () => repository.updateProfile(
                                    SppgProfile(
                                      name: _nameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      phone: _phoneController.text.trim(),
                                      location: _addressController.text.trim(),
                                      institutionName: _institutionController
                                          .text
                                          .trim(),
                                    ),
                                  ),
                                  successMessage: 'Profil berhasil disimpan.',
                                );
                              },
                        child: Text(
                          state.status == ApiStatus.loading
                              ? 'Menyimpan...'
                              : 'Simpan Perubahan',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
