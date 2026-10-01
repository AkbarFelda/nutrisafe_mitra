import 'package:nutrisafe_mitra/core/constants/app_assets.dart';

import '../../../core/widgets/responsive_content.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';

import 'widgets/auth_header.dart';
import 'widgets/auth_form_card.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_account_prompt.dart';
import 'widgets/auth_password_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _institutionNameController = TextEditingController();
  String? _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label wajib diisi.' : null;

  void _submit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Data valid. Layanan pendaftaran belum tersedia.'),
        ),
      );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _institutionNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.loginBackground,
    body: SafeArea(
      child: ResponsiveContent(
        maxWidth: 600,
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              AuthHeader(
                bannerHeight: constraints.maxHeight < 400 ? 48 : 170,
                leading: Image.asset(AppAssets.logo, width: 32, height: 32),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      const Text(
                        'Daftar Akun',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                                text: 'Nama Lengkap',
                                icon: AppAssets.userIcon,
                                color: AppColors.textSecondary,
                              ),
                              TextFormField(
                                controller: _fullNameController,
                                validator: (value) =>
                                    _required(value, 'Nama lengkap'),
                              ),
                              const SizedBox(height: 14),
                              const AuthFieldLabel(
                                text: 'Email',
                                icon: AppAssets.emailIcon,
                                color: AppColors.emailIcon,
                              ),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                validator: (value) {
                                  final required = _required(value, 'Email');
                                  if (required != null) return required;
                                  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                          .hasMatch(value!.trim())
                                      ? null
                                      : 'Format email tidak valid.';
                                },
                              ),
                              const SizedBox(height: 14),
                              const AuthFieldLabel(
                                text: 'Password',
                                icon: AppAssets.passwordIcon,
                                color: AppColors.passwordIcon,
                              ),
                              AuthPasswordField(
                                controller: _passwordController,
                                allowReveal: false,
                                validator: (value) =>
                                    _required(value, 'Password'),
                              ),
                              const SizedBox(height: 14),
                              const AuthFieldLabel(
                                text: 'No. Handphone',
                                icon: AppAssets.mobilephoneIcon,
                                color: Colors.indigo,
                              ),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: '81234567890',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text('+62'),
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 0,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  TextInputFormatter.withFunction((
                                    oldValue,
                                    newValue,
                                  ) {
                                    final prefix = RegExp(r'^(?:62|0+)')
                                        .firstMatch(newValue.text);
                                    if (prefix == null) return newValue;
                                    final text = newValue.text.substring(
                                      prefix.end,
                                    );
                                    int offset(int position) =>
                                        (position - prefix.end).clamp(
                                          0,
                                          text.length,
                                        );
                                    return TextEditingValue(
                                      text: text,
                                      selection: TextSelection(
                                        baseOffset: offset(
                                          newValue.selection.baseOffset,
                                        ),
                                        extentOffset: offset(
                                          newValue.selection.extentOffset,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                validator: (value) {
                                  final required = _required(value, 'Nomor HP');
                                  if (required != null) return required;
                                  return RegExp(r'^8[0-9]*$').hasMatch(value!)
                                      ? null
                                      : 'Nomor HP harus diawali 8 setelah +62.';
                                },
                              ),
                              const SizedBox(height: 14),
                              const AuthFieldLabel(
                                text: 'Nama Instansi / Umum',
                                icon: AppAssets.buildingIcon,
                                color: Colors.teal,
                              ),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                itemHeight: null,
                                initialValue: _selectedCategory,
                                validator: (value) =>
                                    _required(value, 'Kategori'),
                                items: ['Instansi', 'Umum']
                                    .map(
                                      (category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(
                                          category,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _selectedCategory = value),
                                icon: const Icon(Icons.keyboard_arrow_down),
                              ),
                              if (_selectedCategory == 'Instansi') ...[
                                const SizedBox(height: 14),
                                const AuthFieldLabel(
                                  text: 'Nama Instansi',
                                  icon: AppAssets.buildingIcon,
                                  color: Colors.blueGrey,
                                ),
                                TextFormField(
                                  controller: _institutionNameController,
                                  validator: (value) =>
                                      _required(value, 'Nama instansi'),
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Masukkan nama instansi / sekolah',
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              AuthPrimaryButton(
                                label: 'Daftar',
                                onPressed: _submit,
                                height: 44,
                              ),
                              const SizedBox(height: 16),
                              AuthAccountPrompt(
                                message: 'Sudah Punya Akun? ',
                                linkLabel: 'Masuk',
                                onTap: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/login');
                                  }
                                },
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
            ],
          ),
        ),
      ),
    ),
  );
}
