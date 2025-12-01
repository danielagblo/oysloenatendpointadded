class ResumeFileInfo {
  final String name;
  final int sizeBytes;
  const ResumeFileInfo({required this.name, required this.sizeBytes});
}

class ServiceApplication {
  final String name;
  final String phone;
  final String email;
  final String location;
  final String? gender;
  final DateTime? dob;
  final String? coverLetter;
  final ResumeFileInfo? resume;

  const ServiceApplication({
    required this.name,
    required this.phone,
    required this.email,
    required this.location,
    this.gender,
    this.dob,
    this.coverLetter,
    this.resume,
  });

  ServiceApplication copyWith({
    String? name,
    String? phone,
    String? email,
    String? location,
    String? gender,
    DateTime? dob,
    String? coverLetter,
    ResumeFileInfo? resume,
  }) {
    return ServiceApplication(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      coverLetter: coverLetter ?? this.coverLetter,
      resume: resume ?? this.resume,
    );
  }
}
