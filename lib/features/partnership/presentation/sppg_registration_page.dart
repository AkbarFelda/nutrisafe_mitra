import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../data/registration_attachment_picker.dart';
import 'widgets/partnership_app_bar.dart';
import 'widgets/registration_documents.dart';
import 'widgets/sppg_form_field.dart';
import 'widgets/sppg_form_section.dart';

class SppgRegistrationPage extends StatefulWidget {
  const SppgRegistrationPage({super.key, this.attachmentPicker});
  final RegistrationAttachmentPicker? attachmentPicker;

  @override
  State<SppgRegistrationPage> createState() => _SppgRegistrationPageState();
}

class _SppgRegistrationPageState extends State<SppgRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _pendaftarController = TextEditingController();
  final _instansiController = TextEditingController();
  final _nikNpwpController = TextEditingController();
  final _emailController = TextEditingController();
  final _hpController = TextEditingController();
  final _namaSppgController = TextEditingController();
  final _alamatSppgController = TextEditingController();
  final _kapasitasController = TextEditingController();
  late final RegistrationAttachmentPicker _picker;
  List<RegistrationAttachment> _attachments = [];
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _picker = widget.attachmentPicker ?? NativeRegistrationAttachmentPicker();
  }

  @override
  void dispose() {
    for (final controller in [
      _pendaftarController,
      _instansiController,
      _nikNpwpController,
      _emailController,
      _hpController,
      _namaSppgController,
      _alamatSppgController,
      _kapasitasController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Kolom ini wajib diisi.' : null;

  void _validate() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Data valid dengan ${_attachments.length} lampiran. Pengiriman pendaftaran belum tersedia.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.loginBackground,
    appBar: const PartnershipAppBar(
      title: 'Pendaftaran Mitra SPPG Baru',
      fallbackRoute: '/partnership/status',
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: AutofillGroup(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SppgFormSection(
                        title: 'Data Mitra',
                        children: [
                          SppgFormField(
                            label: 'Nama Pendaftar',
                            controller: _pendaftarController,
                            validator: _required,
                            autofillHints: const [AutofillHints.name],
                          ),
                          SppgFormField(
                            label: 'Nama Instansi',
                            controller: _instansiController,
                            optional: true,
                          ),
                          SppgFormField(
                            label: 'NIK / NPWP',
                            controller: _nikNpwpController,
                            validator: _required,
                          ),
                          SppgFormField(
                            label: 'E-Mail',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              final required = _required(value);
                              if (required != null) return required;
                              return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                      .hasMatch(value!.trim())
                                  ? null
                                  : 'Format email tidak valid.';
                            },
                          ),
                          SppgFormField(
                            label: 'Nomor HP',
                            controller: _hpController,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+]'),
                              ),
                            ],
                            validator: (value) {
                              final required = _required(value);
                              if (required != null) return required;
                              return RegExp(r'^(?:0|\+?62)8[0-9]+$')
                                      .hasMatch(value!.trim())
                                  ? null
                                  : 'Gunakan nomor HP berawalan 08 atau +628.';
                            },
                          ),
                        ],
                      ),
                      SppgFormSection(
                        title: 'Data SPPG',
                        children: [
                          SppgFormField(
                            label: 'Nama SPPG',
                            controller: _namaSppgController,
                            validator: _required,
                          ),
                          SppgFormField(
                            label: 'Alamat SPPG',
                            controller: _alamatSppgController,
                            validator: _required,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                          ),
                          SppgFormField(
                            label: 'Kapasitas Produksi (Porsi / Hari)',
                            controller: _kapasitasController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              final capacity = int.tryParse(value ?? '');
                              return capacity == null || capacity <= 0
                                  ? 'Kapasitas harus berupa angka lebih dari 0.'
                                  : null;
                            },
                          ),
                        ],
                      ),
                      SppgFormSection(
                        title: 'Upload Dokumen',
                        children: [
                          RegistrationDocuments(
                            picker: _picker,
                            onChanged: (files) => _attachments = files,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Lampiran tersimpan sementara selama halaman ini dibuka dan belum dikirim.',
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FilledButton(
                          onPressed: _validate,
                          child: const Text('Periksa Formulir'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
