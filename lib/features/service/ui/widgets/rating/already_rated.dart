import 'package:flutter/material.dart';
import '../../../../service/domain/models/rating_model.dart';

class AlreadyRatedWidget extends StatelessWidget {
  final RatingModel rating;

  const AlreadyRatedWidget({
    super.key,
    required this.rating,
  });
  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildStarRow(int starCount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Icon(
            i < starCount ? Icons.star : Icons.star_border,
            color: const Color(0xFFFFC107),
            size: 18,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = rating.partnerAvatar;
    final name = rating.partnerName;
    final jobTitle = rating.serviceTitle;
    final reviewTime = rating.ratedAt ?? DateTime.now();
    final images = rating.images ?? [];
    final comment = rating.comment ?? '';
    final location = rating.place;
    final jobTimeStr = _formatDateTime(rating.startAt);
    final durationStr = _formatDuration(rating.durationSecs);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Icon(Icons.person, color: Colors.grey[500], size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003E77))),
                      const SizedBox(height: 4),
                      Row(children: [
                        _buildStarRow(rating.stars ?? 0),
                        const SizedBox(width: 8),
                      ])
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(_formatDateTime(reviewTime),
                style: const TextStyle(color: Colors.grey, fontSize: 12)),

            const SizedBox(height: 12),
            if (images.isNotEmpty) ...[
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        images[i],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => Container(
                          width: 80, height: 80, color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      )
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (comment.isNotEmpty) ...[
              Text(comment,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
              const SizedBox(height: 12),
            ],

            const Divider(),
            if (jobTitle.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jobTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF003E77))),
                  const SizedBox(height: 6),

                  _buildRichInfo('Thời gian: ', jobTimeStr, Colors.green),
                  const SizedBox(height: 4),
                  _buildRichInfo('Thời lượng: ', durationStr, Colors.red),

                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildRichInfo('Địa điểm: ', location, const Color(0xFF003E77)),
                  ]
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichInfo(String label, String value, Color valueColor) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(fontSize: 14, color: valueColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}