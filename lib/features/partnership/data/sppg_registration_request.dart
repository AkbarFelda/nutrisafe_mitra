import 'dart:typed_data';

class SppgRegistrationRequest {
  const SppgRegistrationRequest({
    required this.registrantName,
    required this.institutionName,
    required this.nikNpwp,
    required this.email,
    required this.phone,
    required this.sppgName,
    required this.sppgAddress,
    required this.productionCapacity,
    required this.proposalName,
    required this.proposalBytes,
    required this.kitchenPhotoName,
    required this.kitchenPhotoBytes,
  });

  final String registrantName;
  final String institutionName;
  final String nikNpwp;
  final String email;
  final String phone;
  final String sppgName;
  final String sppgAddress;
  final int productionCapacity;
  final String proposalName;
  final Uint8List proposalBytes;
  final String kitchenPhotoName;
  final Uint8List kitchenPhotoBytes;
}
