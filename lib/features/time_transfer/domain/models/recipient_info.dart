class RecipientInfo {
  final String id;
  final String fullName;
  final String? avatarUrl;
  RecipientInfo({required this.id, required this.fullName, this.avatarUrl});

  factory RecipientInfo.fromJson(Map<String, dynamic> json) {
    return RecipientInfo(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'] is String ? json['avatar_url'] as String? : null,
    );
  }
}