import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/registration_attachment_picker.dart';

class RegistrationAttachment {
  const RegistrationAttachment({
    required this.name,
    required this.bytes,
    required this.isPdf,
  });
  final String name;
  final Uint8List bytes;
  final bool isPdf;
}

class RegistrationDocuments extends StatefulWidget {
  const RegistrationDocuments({
    super.key,
    required this.picker,
    required this.onChanged,
  });
  final RegistrationAttachmentPicker picker;
  final ValueChanged<List<RegistrationAttachment>> onChanged;

  @override
  State<RegistrationDocuments> createState() => _RegistrationDocumentsState();
}

class _RegistrationDocumentsState extends State<RegistrationDocuments> {
  static const _maxBytes = 10 * 1024 * 1024;
  static const _maxFiles = 5;
  final List<RegistrationAttachment> _files = [];
  bool _busy = true;
  bool _choosingSource = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _recover();
  }

  Future<void> _recover() async {
    try {
      final photos = await widget.picker.recoverPhotos();
      for (final photo in photos) {
        if (!mounted) return;
        await _add(photo, isPdf: false);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Foto sebelumnya tidak dapat dipulihkan. Silakan pilih ulang.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add(XFile file, {required bool isPdf}) async {
    if (_files.length >= _maxFiles) {
      throw const FormatException('Maksimal 5 lampiran.');
    }
    if (await file.length() > _maxBytes) {
      throw const FormatException('Ukuran file maksimal 10 MB.');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('File kosong tidak dapat dilampirkan.');
    }
    if (bytes.length > _maxBytes) {
      throw const FormatException('Ukuran file maksimal 10 MB.');
    }
    if (isPdf &&
        (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-')) {
      throw const FormatException('Pilih dokumen PDF yang valid.');
    }
    if (!mounted) return;
    setState(
      () => _files.add(
        RegistrationAttachment(name: file.name, bytes: bytes, isPdf: isPdf),
      ),
    );
    widget.onChanged(List.unmodifiable(_files));
  }

  Future<void> _pick({bool pdf = false, bool camera = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = pdf
          ? await widget.picker.pickPdf()
          : await widget.picker.pickPhoto(camera: camera);
      if (file != null && mounted) await _add(file, isPdf: pdf);
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on PlatformException catch (error) {
      if (mounted) {
        setState(
          () => _error =
              error.code.toLowerCase().contains('access') ||
                  error.code.toLowerCase().contains('denied')
              ? 'Izin kamera atau foto ditolak. Izinkan melalui pengaturan perangkat, lalu coba lagi.'
              : 'Tidak dapat membuka pemilih file atau kamera. Silakan coba lagi.',
        );
      }
    } on UnsupportedError {
      if (mounted) {
        setState(
          () => _error =
              'Kamera tidak tersedia di platform ini. Pilih foto dari galeri.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Lampiran tidak dapat dibaca. Silakan pilih file lain.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _choosePhotoSource() async {
    if (_busy || _choosingSource) return;
    setState(() => _choosingSource = true);
    final camera = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Foto Dapur',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(sheetContext, true),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Pilih dari File'),
              onTap: () => Navigator.pop(sheetContext, false),
            ),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _choosingSource = false);
    if (camera != null) await _pick(camera: camera);
  }

  Widget _attachmentTile(RegistrationAttachment file) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: file.isPdf
        ? const Icon(Icons.picture_as_pdf_outlined)
        : Image.memory(
            file.bytes,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            cacheWidth: 144,
            errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
          ),
    title: Text(file.name, maxLines: 2, overflow: TextOverflow.ellipsis),
    subtitle: Text('${(file.bytes.length / 1024).toStringAsFixed(0)} KB'),
    trailing: IconButton(
      tooltip: 'Hapus ${file.name}',
      onPressed: _busy || _choosingSource
          ? null
          : () {
              setState(() => _files.remove(file));
              widget.onChanged(List.unmodifiable(_files));
            },
      icon: const Icon(Icons.close),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final enabled = !_busy && !_choosingSource && _files.length < _maxFiles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _UploadField(
          label: 'Upload Proposal (PDF)',
          onPressed: enabled ? () => _pick(pdf: true) : null,
        ),
        for (final file in _files.where((file) => file.isPdf))
          _attachmentTile(file),
        const SizedBox(height: 12),
        _UploadField(
          label: 'Foto Dapur',
          onPressed: enabled ? _choosePhotoSource : null,
        ),
        for (final file in _files.where((file) => !file.isPdf))
          _attachmentTile(file),
        if (_busy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'masing-masing 10 MB.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _UploadField extends StatelessWidget {
  const _UploadField({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 64),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      side: BorderSide(color: Theme.of(context).colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.centerLeft,
    ),
    child: Row(
      children: [
        const Icon(Icons.file_upload_outlined, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
          ),
        ),
      ],
    ),
  );
}
