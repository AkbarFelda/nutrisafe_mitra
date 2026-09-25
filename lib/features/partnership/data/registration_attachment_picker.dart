import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

abstract class RegistrationAttachmentPicker {
  Future<XFile?> pickPdf();
  Future<XFile?> pickPhoto({required bool camera});
  Future<List<XFile>> recoverPhotos();
}

class NativeRegistrationAttachmentPicker
    implements RegistrationAttachmentPicker {
  final ImagePicker _images = ImagePicker();

  @override
  Future<XFile?> pickPdf() => openFile(
    acceptedTypeGroups: const [
      XTypeGroup(
        label: 'PDF',
        extensions: ['pdf'],
        mimeTypes: ['application/pdf'],
        uniformTypeIdentifiers: ['com.adobe.pdf'],
      ),
    ],
  );

  @override
  Future<XFile?> pickPhoto({required bool camera}) {
    if (!camera) {
      return openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Foto',
            extensions: ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'],
            mimeTypes: [
              'image/jpeg',
              'image/png',
              'image/webp',
              'image/heic',
              'image/heif',
            ],
            uniformTypeIdentifiers: [
              'public.jpeg',
              'public.png',
              'org.webmproject.webp',
              'public.heic',
              'public.heif',
            ],
          ),
        ],
      );
    }
    return _images.pickImage(
      source: ImageSource.camera,
      maxWidth: 2400,
      maxHeight: 2400,
      imageQuality: 85,
      requestFullMetadata: false,
    );
  }

  @override
  Future<List<XFile>> recoverPhotos() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return [];
    final result = await _images.retrieveLostData();
    if (result.exception != null) throw result.exception!;
    return result.files ?? [];
  }
}
