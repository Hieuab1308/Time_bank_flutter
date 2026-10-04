import 'package:flutter/material.dart';
import 'bottom_glow_painter.dart';
import 'nav_item_data.dart';

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.data,
    required this.isActive,
    required this.brandColor,
    required this.onTap,
  });

  final NavItemData data;
  final bool isActive;
  final Color brandColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Colors.white.withOpacity(0.60);
    final bool isQr = data.emphasize;
    final bool squareInactive = isQr && !isActive;
  final double iconSize = isQr ? 30 : 24;

  final edge = isQr
    ? (isActive ? const EdgeInsets.symmetric(vertical: 10, horizontal: 14)
    : const EdgeInsets.symmetric(vertical: 8, horizontal: 8))
    : const EdgeInsets.symmetric(vertical: 8, horizontal: 12);

    final Color bg = isQr ? (isActive ? Colors.white : Colors.white.withOpacity(0.92)) : Colors.transparent;
    final Color iconColor = isQr ? (isActive ? brandColor : brandColor.withOpacity(0.80))
        : (isActive ? Colors.white : inactiveColor);
    final Color textColor = isQr ? Colors.transparent : (isActive ? Colors.white : inactiveColor);
    final List<BoxShadow>? shadow = isQr
        ? const [BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 3))]
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          final messenger = ScaffoldMessenger.maybeOf(context);
          if (messenger != null) {
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(data.label),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(isQr ? (squareInactive ? 18 : 24) : 22),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: edge,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(isQr ? (squareInactive ? 18 : 24) : 22),
            boxShadow: shadow,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isQr)
                    SizedBox(
                      height: iconSize + 16,
                      width: iconSize + 16,
                      child: Center(
                        child: Image.asset(
                          'assets/images/qr_nav.png',
                          width: iconSize + 6,
                          height: iconSize + 6,
                          fit: BoxFit.contain,
                          color: iconColor,
                          colorBlendMode: BlendMode.srcIn,
                          errorBuilder: (_, __, ___) => Icon(data.icon, size: iconSize, color: iconColor),
                        ),
                      ),
                    )
                  else ...[
                    Icon(data.icon, size: iconSize, color: iconColor),
                    const SizedBox(height: 6),
                    Tooltip(
                      message: data.label,
                      waitDuration: Duration(milliseconds: 300),
                      showDuration: Duration(seconds: 3),
                      child: SizedBox(
                        width: 72,
                          child: Text(
                            data.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: textColor, letterSpacing: -0.1),
                          ),
                      ),
                    ),
                  ],
                ],
              ),
              if (isActive && !isQr)
                Positioned(
                  left: 0, right: 0, bottom: -12,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                    builder: (context, t, _) {
                      final double boxSide = (iconSize + 72).clamp(96, 180);
                      return Opacity(
                        opacity: t,
                        child: IgnorePointer(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: boxSide, height: boxSide,
                              child: CustomPaint(painter: BottomGlowPainter(intensity: t, overlay: true, circular: false, halfCircle: true)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
