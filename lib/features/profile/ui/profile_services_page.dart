import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProfileHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? avatarUrl;
  final bool isSelf;
  final double appBarHeight;
  final int followers;
  final int points;
  final int following;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.subtitle,
    this.avatarUrl,
    this.isSelf = false,
    this.followers = 0,
    this.points = 0,
    this.following = 0,
    this.appBarHeight = 64,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const headerBlue = Colors.white;
    const double bandHeight = 140.0;
    const double outerSize = 112.0;
    const double outerPadding = 2.0;

    final statusBar = MediaQuery.of(context).padding.top;
    final safeTop = statusBar + 8;
    final preferredTop = bandHeight - (outerSize / 2);
    final double avatarTop = math.max(preferredTop, safeTop);

    final avatarBottom = avatarTop + outerSize;
    final contentSpacing = math.max(0.0, avatarBottom - bandHeight + 6.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: bandHeight,
              width: double.infinity,
              color: headerBlue,
            ),
            Positioned(
              top: avatarTop,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: outerSize,
                      height: outerSize,
                      padding: const EdgeInsets.all(outerPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: (outerSize / 2) - outerPadding,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl!)
                            : const AssetImage('assets/images/avatar.png')
                        as ImageProvider,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: contentSpacing),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87)),
              const SizedBox(height: 6),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statColumn(following, 'Đã follow'),
                  const SizedBox(width: 24),
                  Container(height: 44, width: 1, color: Colors.grey[300]),
                  const SizedBox(width: 24),
                  _statColumn(followers, 'Follower'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statColumn(int value, String label) {
    final display = value >= 1000000
        ? '${(value / 1000000).toStringAsFixed(0)}M'
        : value.toString();
    return Column(
      children: [
        Text(display,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}