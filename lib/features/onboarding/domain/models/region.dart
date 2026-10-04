class Region {
  final String id;
  final String name;
  final String type;
  final String? parentId;
  final int? code;
  final String? codename;

  Region({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.code,
    this.codename,
  });

  factory Region.fromJson(Map<String, dynamic> j) {
    final dynamic rawId = j['id'] ?? j['code'];
    if (rawId == null) {
      throw const FormatException('Region missing id/code');
    }

    final String safeType =
    (j['type'] ?? j['division_type'] ?? 'district').toString();

    final String safeName = (j['name'] ?? '').toString();
    if (safeName.isEmpty) {
      throw const FormatException('Region missing name');
    }

    return Region(
      id: rawId.toString(),
      name: safeName,
      type: safeType,
      parentId: j['parent_id']?.toString(),
      code: (j['code'] is int) ? j['code'] as int : int.tryParse('${j['code']}'),
      codename: j['codename']?.toString(),
    );
  }
}
