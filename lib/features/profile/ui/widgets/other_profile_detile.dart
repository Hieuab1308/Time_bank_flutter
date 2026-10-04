import 'package:flutter/material.dart';
import '../../domain/profile.dart';

class OtherProfileDetile extends StatelessWidget {
  final Profile profile;
  final Map<String, bool>? visibility;
  final int followersCount;

  const OtherProfileDetile(
      {Key? key,
      required this.profile,
      this.visibility,
      this.followersCount = 0})
      : super(key: key);

  bool isVisibleKey(String key) =>
      visibility == null ? true : (visibility![key] ?? true);

  String _formatDate(DateTime d) {
    final localDate = d.toLocal();
    return '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
  }

  IconData _iconForKey(String key) {
    final k = key.toLowerCase();
    if (k.contains('facebook')) return Icons.facebook;
    if (k.contains('insta') || k.contains('instagram')) return Icons.camera_alt;
    if (k.contains('tiktok')) return Icons.music_note;
    return Icons.link;
  }

  Color _colorForKey(BuildContext context, String key) {
    final k = key.toLowerCase();
    if (k.contains('facebook')) return const Color(0xFF1877F2);
    if (k.contains('insta') || k.contains('instagram'))
      return const Color(0xFFE1306C);
    if (k.contains('tiktok')) return const Color(0xFF010101);
    return Theme.of(context).primaryColor;
  }

  Widget _row(BuildContext context, IconData icon, String label, String value,
      Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 14, color: Colors.black87, fontFamily: 'Roboto'),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = const Color(0xFF003E77);

    final regionText =
        profile.fullRegionAddress ?? profile.regionName ?? profile.regionId;
    final streetText = profile.street;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (isVisibleKey('region') && regionText != null) ...[
              _row(context, Icons.location_on, 'Đến từ', regionText, iconColor),
              const SizedBox(height: 8),
            ],

            if (isVisibleKey('work') &&
                profile.workAddress != null &&
                profile.workAddress!.isNotEmpty) ...[
              _row(context, Icons.work, 'Làm việc tại', profile.workAddress!,
                  iconColor),
              const SizedBox(height: 8),
            ],

            if (isVisibleKey('birthDate') && profile.birthDate != null) ...[
              _row(context, Icons.cake, 'Ngày sinh',
                  _formatDate(profile.birthDate!), iconColor),
              const SizedBox(height: 8),
            ],

            if (profile.description != null &&
                profile.description!.isNotEmpty) ...[
              _row(context, Icons.info_outline, 'Mô tả', profile.description!,
                  iconColor),
              const SizedBox(height: 8),
            ],

            if (isVisibleKey('street') &&
                streetText != null &&
                streetText.isNotEmpty) ...[
              _row(context, Icons.home, 'Địa chỉ', streetText, iconColor),
              const SizedBox(height: 8),
            ],

            if (isVisibleKey('study') &&
                profile.studyAddress != null &&
                profile.studyAddress!.isNotEmpty) ...[
              _row(context, Icons.school, 'Học tập tại', profile.studyAddress!,
                  iconColor),
              const SizedBox(height: 8),
            ],

            if (profile.socialNetwork != null &&
                profile.socialNetwork!.isNotEmpty) ...[
              for (final e in profile.socialNetwork!.entries) ...[
                if (isVisibleKey(e.key) && e.value.isNotEmpty) ...[
                  _row(
                      context,
                      _iconForKey(e.key),
                      e.key[0].toUpperCase() + e.key.substring(1),
                      e.value,
                      _colorForKey(context, e.key)),
                  const SizedBox(height: 8),
                ],
              ],
            ],

          ],
        ),
      ),
    );
  }
}
