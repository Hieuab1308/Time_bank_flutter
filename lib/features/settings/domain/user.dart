class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? json['name'] as String? ?? 'Chưa có tên',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}