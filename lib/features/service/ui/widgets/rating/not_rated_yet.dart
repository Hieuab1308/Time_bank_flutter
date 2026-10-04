import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/rating/rating_service_page.dart';
import 'package:time_bank_flutter/features/service/domain/models/rating_model.dart';

class NotRatedYetWidget extends StatelessWidget {
  final List<RatingModel> pendingList;
  final VoidCallback? onRatingSuccess;

  const NotRatedYetWidget({
    super.key,
    required this.pendingList,
    this.onRatingSuccess,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/thong_bao.png', width: 150, height: 150),
            const SizedBox(height: 16),
            const Text('Không có đánh giá nào cần thực hiện',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: pendingList.length,
        itemBuilder: (context, index) {
          final item = pendingList[index];
          return NotRatedYetCard(
            item: item,
            onRatingSuccess: onRatingSuccess,
          );
        },
      ),
    );
  }
}

class NotRatedYetCard extends StatelessWidget {
  final RatingModel item;
  final VoidCallback? onRatingSuccess;

  const NotRatedYetCard({
    super.key,
    required this.item,
    this.onRatingSuccess,
  });

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RatingServicePage(
              ratingModel: item,
            )));

        if (result == true) {
          onRatingSuccess?.call();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF003E77),
                  backgroundImage: (item.partnerAvatar != null)
                      ? NetworkImage(item.partnerAvatar!)
                      : null,
                  child: item.partnerAvatar == null
                      ? const Icon(Icons.person, color: Colors.white, size: 28)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.partnerName,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003E77))),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.serviceTitle,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF003E77))),
                        const SizedBox(height: 8),
                        _CardLabelValue(
                            label: 'Thời gian',
                            value: _formatDateTime(item.startAt),
                            valueColor: const Color(0xFF2E7D32)),
                        const SizedBox(height: 6),
                        _CardLabelValue(
                            label: 'Thời lượng',
                            value: _formatDuration(item.durationSecs),
                            valueColor: const Color(0xFFCC0404),
                            isBold: true),
                        const SizedBox(height: 6),
                        if (item.place.isNotEmpty)
                          _CardLabelValue(label: 'Địa điểm', value: item.place),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 4,
                        runSpacing: 4,
                        children: item.skills.map((skill) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0DC06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(fontSize: 10, color: Colors.black),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _CardLabelValue(
      {required this.label, required this.value, this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 70,
          child: Text('$label:',
              style: const TextStyle(fontSize: 12, color: Colors.black87))),
      const SizedBox(width: 4),
      Expanded(
          child: Text(value,
              style: TextStyle(
                fontSize: 15,
                color: valueColor ?? const Color(0xFF003E77),
                fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              ),
              softWrap: false,
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}