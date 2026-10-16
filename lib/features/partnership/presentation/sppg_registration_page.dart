import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../data/registration_attachment_picker.dart';
import '../data/sppg_registration_repository.dart';
import '../data/sppg_registration_request.dart';
import 'sppg_registration_cubit.dart';
import 'widgets/partnership_app_bar.dart';
import 'widgets/registration_documents.dart';
import 'widgets/sppg_form_field.dart';
import 'widgets/sppg_form_section.dart';

class SppgRegistrationPage extends StatefulWidget {
  const SppgRegistrationPage({
    super.key,
    this.attachmentPicker,
    this.repository,
    this.fallbackRoute = '/partnership/status',
  });
  final RegistrationAttachmentPicker? attachmentPicker;
  final SppgRegistrationRepository? repository;
  final String fallbackRoute;

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

  void _submit(BuildContext context) {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final proposal = _attachments.where((file) => file.isPdf).firstOrNull;
    final kitchenPhoto = _attachments.where((file) => !file.isPdf).firstOrNull;
    if (proposal == null || kitchenPhoto == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Proposal PDF dan foto dapur wajib dilampirkan.'),
          ),
        );
      return;
    }

    FocusScope.of(context).unfocus();
    final repository = widget.repository;
    if (repository == null) return;
    context.read<SppgRegistrationCubit>().submit(
      SppgRegistrationRequest(
        registrantName: _pendaftarController.text.trim(),
        institutionName: _instansiController.text.trim(),
        nikNpwp: _nikNpwpController.text.trim(),
        email: _emailController.text.trim(),
        phone: _hpController.text.trim(),
        sppgName: _namaSppgController.text.trim(),
        sppgAddress: _alamatSppgController.text.trim(),
        productionCapacity: int.parse(_kapasitasController.text),
        proposalName: proposal.name,
        proposalBytes: proposal.bytes,
        kitchenPhotoName: kitchenPhoto.name,
        kitchenPhotoBytes: kitchenPhoto.bytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = widget.repository;
    if (repository == null) {
      return _buildScaffold(context, const SppgRegistrationState());
    }
    return BlocProvider(
      create: (_) => SppgRegistrationCubit(repository),
      child: BlocConsumer<SppgRegistrationCubit, SppgRegistrationState>(
        listener: (context, state) {
          if (state.status == SppgRegistrationStatus.success) {
            _showSuccessDialog(context);
            return;
          }
          final message = state.message;
          if (state.status != SppgRegistrationStatus.failure ||
              message == null) {
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: _buildScaffold,
      ),
    );
  }

  Future<void> _showSuccessDialog(BuildContext pageContext) async {
    await showDialog<void>(
      context: pageContext,
      barrierDismissible: false,
      builder: (dialogContext) => SppgRegistrationSuccessDialog(
        onConfirmed: () => Navigator.of(dialogContext).pop(),
      ),
    );
    if (mounted) context.go(widget.fallbackRoute);
  }

  Widget _buildScaffold(
    BuildContext context,
    SppgRegistrationState registrationState,
  ) => Scaffold(
    backgroundColor: AppColors.loginBackground,
    appBar: PartnershipAppBar(
      title: 'Daftar Jadi Mitra SPPG',
      fallbackRoute: widget.fallbackRoute,
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
                            'Proposal PDF dan satu foto dapur wajib dilampirkan.',
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FilledButton(
                          onPressed:
                              registrationState.status ==
                                  SppgRegistrationStatus.loading
                              ? null
                              : () => _submit(context),
                          child:
                              registrationState.status ==
                                  SppgRegistrationStatus.loading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Kirim Pendaftaran'),
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

class SppgRegistrationSuccessDialog extends StatelessWidget {
  const SppgRegistrationSuccessDialog({super.key, required this.onConfirmed});

  final VoidCallback onConfirmed;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: const Color(0xFFF3F3F3),
    insetPadding: const EdgeInsets.symmetric(horizontal: 32),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF009C25), width: 2),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF009C25),
                size: 27,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pendaftaran Berhasil!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Silahkan tunggu email konfirmasi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                key: const Key('registration-success-ok'),
                onPressed: onConfirmed,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00A824),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
