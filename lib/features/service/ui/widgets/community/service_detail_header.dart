import 'package:flutter/material.dart';
import '../../../domain/models/service.dart';
import '../../page/report_page.dart';

class ServiceDetailHeader extends StatelessWidget {
  final Service service;
  final bool isFavorited;
  final VoidCallback? onFavoritePressed;
  final bool isMyService;
  final bool showAllSpecializations;

  const ServiceDetailHeader({
    super.key,
    required this.service,
    this.isFavorited = false,
    this.onFavoritePressed,
    this.isMyService = false,
    this.showAllSpecializations = false,
  });

  void _showReportServiceSheet(BuildContext context) {
    final reportReasons = [
      'Dịch vụ lừa đảo/không có thật',
      'Nội dung không phù hợp/Vi phạm chính sách',
      'Spam/Quảng cáo sai sự thật',
      'Ngôn từ đả kích/Thù địch',
      'Khác...',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Báo cáo dịch vụ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF003E77),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...reportReasons.map((reason) {
                  return ListTile(
                    title: Text(reason, style: const TextStyle(fontSize: 16)),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportPage(
                            reportedUserName: service.title, // Tên dịch vụ
                            reportReason: reason,
                            targetId: service.id, // << ID Dịch vụ
                            targetType: 'service', // << Loại đối tượng
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibilityIcon = service.isPublic ? Icons.person : Icons.group;

    final List<String> fromSkillNames = (service.skillNames ?? <String>[])
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final List<String> fromProviderSpecialization =
        (service.providerSpecialization ?? '')
            .split(',')
            .map((e) => e.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    final List<String> specializationsList =
        fromSkillNames.isNotEmpty ? fromSkillNames : fromProviderSpecialization;

    final specializations = specializationsList.isNotEmpty
        ? specializationsList.toSet().toList()
        : ['Chưa có'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF003E77),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    service.isPublic ? Icons.group : Icons.person,
                    size: 25,
                    color: const Color(0xFF003E77),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(
                  Icons.more_horiz,
                  size: 25,
                  color: Color(0xFF003E77),
                ),
              ),
              color: Colors.white,
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.report, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Báo cáo dịch vụ'),
                    ],
                  ),
                ),
                if (isMyService) ...[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Sửa')
                    ]),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Xóa')
                    ]),
                  ),
                ]
              ],
              onSelected: (value) {
                if (value == 'report') {
                  _showReportServiceSheet(context);
                } else if (value == 'edit') {
                  //
                } else if (value == 'delete') {
                  //
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ... (Phần hiển thị thời gian/địa điểm giữ nguyên như cũ)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Thời gian: ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      Text(
                        _formatDateTime(service.preferredStart),
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF419C23)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Thời lượng: ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      Text(
                        _formatDurationHMS(service.minSlotMinutes),
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.red[600],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Địa điểm: ${service.place ?? 'Chưa xác định'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.work, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Chuyên môn: ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      Flexible(
                        child: _buildSpecializationTags(
                          context,
                          specializations,
                          showAllSpecializations,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onFavoritePressed != null)
              Container(
                margin: const EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: onFavoritePressed,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      size: 35,
                      color: isFavorited ? Colors.red : const Color(0xFF003E77),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecializationTags(
      BuildContext context, List<String> tags, bool showAll) {
    const double maxChipWidth = 100;
    const double chipHeight = 20;
    const Color chipColor = Color(0xFFE0DC06);
    const Color textColor = Color(0xFF000000);
    const double fontSize = 12;
    final BorderRadius borderRadius = BorderRadius.circular(6);

    if (tags.isEmpty || (tags.length == 1 && tags[0] == 'Chưa có')) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxChipWidth),
        child: SizedBox(
          height: chipHeight,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            decoration: BoxDecoration(
              color: chipColor,
              borderRadius: borderRadius,
            ),
            child: const Text(
              'Chưa có',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
              ),
            ),
          ),
        ),
      );
    }

    if (showAll || tags.length == 1) {
      return LayoutBuilder(builder: (context, constraints) {
        final double chipWidth =
            (constraints.maxWidth / 3).clamp(50, maxChipWidth);

        return Wrap(
          spacing: 8.0,
          runSpacing: 6.0,
          children: tags
              .map((tag) => ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: chipWidth),
                    child: SizedBox(
                      height: chipHeight,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                        decoration: BoxDecoration(
                          color: chipColor,
                          borderRadius: borderRadius,
                        ),
                        child: Text(
                          tag,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: fontSize,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      });
    } else {
      return IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxChipWidth),
              child: SizedBox(
                height: chipHeight,
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: borderRadius,
                  ),
                  child: Text(
                    tags[0],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: fontSize,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _showAllSpecializations(context, tags),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxChipWidth),
                child: SizedBox(
                  height: chipHeight,
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: borderRadius,
                    ),
                    child: Text(
                      '...+${tags.length - 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showAllSpecializations(BuildContext context, List<String> tags) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Tất cả chuyên môn',
            style: TextStyle(
              color: Color(0xFF003E77),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tags
                  .map((tag) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0DC06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Đóng',
                style: TextStyle(color: Color(0xFF003E77)),
              ),
            ),
          ],
        );
      },
    );
  }

  static String _formatDurationHMS(int seconds) {
    final hours = seconds ~/ 3600;
    final remainingSeconds = seconds % 3600;
    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime? t) {
    if (t == null) return 'Chưa xác định';
    final local = t.toUtc().add(const Duration(hours: 7));

    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
