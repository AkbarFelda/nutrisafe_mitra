class SppgProfile {
  const SppgProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.institutionName,
  });

  final String name;
  final String email;
  final String phone;
  final String location;
  final String institutionName;

  factory SppgProfile.fromJson(Map<String, dynamic> json) => SppgProfile(
    name: '${json['name'] ?? json['sppg_name'] ?? ''}',
    email: '${json['email'] ?? ''}',
    phone: '${json['phone'] ?? ''}',
    location: '${json['lokasi'] ?? json['location'] ?? json['address'] ?? ''}',
    institutionName: '${json['institution_name'] ?? ''}',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'lokasi': location,
    'institution_name': institutionName,
  };
}
