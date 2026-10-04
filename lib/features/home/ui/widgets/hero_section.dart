import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/home_models.dart';
import '../home_typography.dart';
import 'package:time_bank_flutter/features/notification/providers/notification_providers.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({
    super.key,
    required this.summary,
    required this.isHidden,
    required this.onToggleHidden,
    required this.onNotificationsTap,
    this.backgroundAsset = "assets/images/background.png",
  });

  final HomeSummary summary;
  final bool isHidden;
  final VoidCallback onToggleHidden;
  final VoidCallback onNotificationsTap;
  final String backgroundAsset;

  Widget _buildAvatar(BuildContext context) {
    final url = summary.avatarUrl;
    if (url != null &&
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return CircleAvatar(
        radius: 35,
        backgroundImage: NetworkImage(url),
      );
    } else {
      return CircleAvatar(
        radius: 35,
        backgroundColor: Colors.grey.shade300,
        child: Icon(
          Icons.person_outline,
          size: 40,
          color: Colors.grey.shade600,
        ),
      );
    }
  }

  Widget _buildRatingBadge() {
    final double rating = summary.rating;
    final bool hasRating = rating > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              Icons.star_rounded,
              color: hasRating ? Colors.orange : Colors.grey,
              size: 18
          ),
          const SizedBox(width: 4),
          Text(
            hasRating ? rating.toStringAsFixed(1) : "Mới",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hasRating ? Colors.black87 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundAsset),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            right: 16,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onNotificationsTap,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Stack(
                    children: [
                      const Icon(Icons.notifications, color: Colors.white, size: 28),
                      unreadCountAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (e, s) => const SizedBox.shrink(),
                        data: (count) => count > 0
                            ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              count > 99 ? '99+' : count.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAvatar(context),
                    const SizedBox(height: 8),
                    _buildRatingBadge(),
                  ],
                ),

                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Số Dư Thời Gian:",
                              style: HomeTypography.heroBalanceLabel.copyWith(
                                color: Colors.white.withOpacity(0.92),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isHidden ? "••••••" : summary.timeBalance,
                              style: HomeTypography.heroBalanceValue.copyWith(
                                  color: Colors.white,
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 30),
                          icon: Icon(
                            isHidden ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: onToggleHidden,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}