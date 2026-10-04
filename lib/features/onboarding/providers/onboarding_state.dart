class OnboardingState {
  final bool loading;
  final String? error;

  final String? phone;
  final String? phoneToken;
  final String? verificationId;

  final String? fullName;
  final String? email;
  final String? cccd;
  final DateTime? birthdate;
  final String? gender;

  final String? regionId;
  final String? specialization;

  final String? pin;
  final String? password;

  const OnboardingState({
    this.loading = false,
    this.error,
    this.phone,
    this.phoneToken,
    this.verificationId,
    this.fullName,
    this.email,
    this.cccd,
    this.birthdate,
    this.gender,
    this.regionId,
    this.specialization,
    this.pin,
    this.password,
  });

  OnboardingState copyWith({
    bool? loading,
    String? error,
    String? phone,
    String? phoneToken,
    String? verificationId,
    String? fullName,
    String? email,
    String? cccd,
    DateTime? birthdate,
    String? gender,
    String? regionId,
    String? specialization,
    String? pin,
    String? password,
  }) {
    return OnboardingState(
      loading: loading ?? this.loading,
      error: error,
      phone: phone ?? this.phone,
      phoneToken: phoneToken ?? this.phoneToken,
      verificationId: verificationId ?? this.verificationId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      cccd: cccd ?? this.cccd,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      regionId: regionId ?? this.regionId,
      specialization: specialization ?? this.specialization,
      pin: pin ?? this.pin,
      password: password ?? this.password,
    );
  }
}
