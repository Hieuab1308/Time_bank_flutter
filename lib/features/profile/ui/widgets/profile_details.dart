import 'package:flutter/material.dart';
import '../../domain/profile.dart';

class ProfileDetails extends StatefulWidget {
  final Profile profile;
  final Map<String, bool>? visibility;
  final VoidCallback? onEdit;
  final bool showEditButton;

  const ProfileDetails(
      {Key? key,
        required this.profile,
        this.visibility,
        this.onEdit,
        this.showEditButton = true})
      : super(key: key);

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  @override
  void initState() {
    super.initState();
  }

  String _formatDate(DateTime d) {
    final localDate = d.toLocal();
    return '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
  }

  String _formatSocialKey(String key) {
    if (key.isEmpty) return '';
    return key[0].toUpperCase() + key.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Color(0xFF003E77);
    bool isVisibleKey(String key) =>
        widget.visibility == null ? true : (widget.visibility![key] ?? true);

    final regionText = widget.profile.fullRegionAddress ??
        widget.profile.regionName ??
        widget.profile.regionId;
    final streetText = widget.profile.street;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Chi tiết',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (isVisibleKey('region') && regionText != null) ...[
              _row(context, Icons.location_on, 'Đến từ', regionText, iconColor),
              const SizedBox(height: 8),
            ],
            if (isVisibleKey('work') &&
                widget.profile.workAddress != null &&
                widget.profile.workAddress!.isNotEmpty) ...[
              _row(context, Icons.work, 'Làm việc tại',
                  widget.profile.workAddress!, iconColor),
              const SizedBox(height: 8),
            ],
            if (isVisibleKey('birthDate') &&
                widget.profile.birthDate != null) ...[
              _row(context, Icons.cake, 'Ngày sinh',
                  _formatDate(widget.profile.birthDate!), iconColor),
              const SizedBox(height: 8),
            ],
            if (widget.profile.description != null &&
                widget.profile.description!.isNotEmpty) ...[
              _row(context, Icons.info_outline, 'Mô tả',
                  widget.profile.description!, iconColor),
              const SizedBox(height: 8),
            ],
            if (isVisibleKey('street') &&
                streetText != null &&
                streetText.isNotEmpty) ...[
              _row(context, Icons.home, 'Địa chỉ', streetText, iconColor),
              const SizedBox(height: 8),
            ],
            if (isVisibleKey('study') &&
                widget.profile.studyAddress != null &&
                widget.profile.studyAddress!.isNotEmpty) ...[
              _row(context, Icons.school, 'Học tập tại',
                  widget.profile.studyAddress!, iconColor),
              const SizedBox(height: 8),
            ],
            if (widget.profile.socialNetwork != null &&
                widget.profile.socialNetwork!.isNotEmpty) ...[
              for (final e in widget.profile.socialNetwork!.entries) ...[
                if (isVisibleKey(e.key) && e.value.isNotEmpty) ...[
                  _row(
                      context,
                      _iconForKey(e.key),
                      _formatSocialKey(e.key),
                      e.value,
                      _colorForKey(context, e.key)),
                  const SizedBox(height: 8),
                ],
              ],
            ],
            if (widget.showEditButton) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6F5FB),
                    foregroundColor: const Color(0xFF0D4C7B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: const Text('Chỉnh sửa thông tin',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  IconData _iconForKey(String key) {
    final k = key.toLowerCase();
    if (k.contains('facebook')) return Icons.facebook;
    if (k.contains('insta') || k.contains('instagram'))
      return Icons.camera_alt;
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
                fontSize: 14,
                color: Colors.black87,
                fontFamily: 'Roboto',
              ),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}