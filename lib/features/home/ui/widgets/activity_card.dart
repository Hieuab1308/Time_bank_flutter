import 'package:flutter/material.dart';
import '../../domain/models/home_models.dart';
import '../home_typography.dart';


class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onMoreTap,
    this.horizontalPadding = 16.0,
    this.verticalPadding = 8.0,
    this.compact = false,
  });

  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  // Optional layout tweaks for compact mode (used by profile services list)
  final double horizontalPadding;
  final double verticalPadding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // status removed for this card; keep helper in case needed later

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Card body
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 22,
                      spreadRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 12 : 14,
                    compact ? 10 : 12,
                    compact ? 12 : 14,
                    compact ? 8 : 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: compact ? 20 : 24,
                            backgroundColor: Colors.blue.shade100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: activity.avatarUrl != null &&
                                      activity.avatarUrl!.isNotEmpty
                                  ? Image.network(
                                      activity.avatarUrl!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Center(
                                        child: Text(
                                          activity.user.isNotEmpty
                                              ? activity.user[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        activity.user.isNotEmpty
                                            ? activity.user[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: compact ? 8 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.user,
                                  style: HomeTypography.cardUserName.copyWith(
                                    fontSize:
                                        (HomeTypography.cardUserName.fontSize ??
                                                14) +
                                            2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  activity.timeAgo,
                                  style: HomeTypography.cardUserTime.copyWith(
                                    fontSize:
                                        (HomeTypography.cardUserTime.fontSize ??
                                                12) +
                                            1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.more_horiz,
                                color: Color(0xFF0B4F80)),
                            onPressed: onMoreTap,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        activity.title,
                        style: HomeTypography.cardTitle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A3D66),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info rows
                      _info(
                          icon: Icons.calendar_month,
                          value: activity.taskTime,
                          valueColor: const Color(0xFF2E8B2C)),
                      const SizedBox(height: 6),
                      _info(
                          icon: Icons.access_time,
                          value: activity.duration,
                          valueColor: Colors.red),
                      const SizedBox(height: 6),
                      _info(icon: Icons.location_on, value: activity.location),

                      const SizedBox(height: 8),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Specialization tag (matches ServiceCard style)
              Positioned(
                top: 72,
                right: 8,
                child: _buildSpecializationTag(context, activity.tags,
                    chipWidth: 60.0, chipHeight: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === helpers ===
  Widget _info(
      {required IconData icon, required String value, Color? valueColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0B4F80)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            style: HomeTypography.cardInfoValue.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF0B3252),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationTag(BuildContext context, List<String>? tags,
      {double chipWidth = 96.0, double chipHeight = 28.0}) {
    final list = tags ?? <String>[];
    final specialization = list.join(', ');
    if (specialization.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE0DC06),
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Text(
          'Khác',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF003E77),
          ),
        ),
      );
    }

    final parts = specialization
        .split(RegExp(r'[,;|\n]'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE0DC06),
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Text(
          'Khác',
          style: TextStyle(fontSize: 10, color: Color(0xFF000000)),
        ),
      );
    }

    if (parts.length == 1) {
      return SizedBox(
        width: chipWidth,
        height: chipHeight,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0DC06),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            parts[0],
            style: const TextStyle(fontSize: 10, color: Color(0xFF000000)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: chipWidth,
            height: chipHeight,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0DC06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                parts[0],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Color(0xFF000000)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: chipWidth,
            height: chipHeight,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0DC06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '...+${parts.length - 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF000000),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // status removed from UI
}
