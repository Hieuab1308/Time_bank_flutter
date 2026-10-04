import 'package:flutter/material.dart';

class BottomGlowPainter extends CustomPainter {
  final double intensity; // 0..1
  final bool overlay;
  final bool circular;
  final bool halfCircle;
  const BottomGlowPainter({
    required this.intensity,
    this.overlay = false,
    this.circular = false,
    this.halfCircle = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final radius = halfCircle ? size.width / 2 : (circular ? size.width * 0.46 : size.width * 0.70);
    final center = halfCircle
        ? Offset(size.width / 2, size.height)
        : Offset(size.width / 2, circular ? size.height / 2 : size.height * 0.55);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = RadialGradient(
      center: halfCircle ? const Alignment(0, 1) : Alignment.center,
      radius: halfCircle ? 1.05 : (circular ? 0.92 : 1.15),
      colors: halfCircle
          ? const [Color(0xFFFFFFFF), Color(0xDDFFFFFF), Color(0x88FFFFFF), Color(0x33FFFFFF), Color(0x05FFFFFF), Color(0x00000000)]
          : const [Color(0xE6FFFFFF), Color(0x99FFFFFF), Color(0x55FFFFFF), Color(0x1AFFFFFF), Color(0x07FFFFFF), Color(0x00FFFFFF)],
      stops: halfCircle
          ? const [0.0, 0.25, 0.48, 0.72, 0.88, 1.0]
          : const [0.0, 0.26, 0.48, 0.70, 0.85, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.saveLayer(rect.inflate(radius * 0.9), Paint());
    canvas.drawCircle(center, radius, paint..color = Colors.white.withOpacity(intensity));

    if (!circular && !halfCircle) {
      final hotspot = Paint()
        ..color = Colors.white.withOpacity(0.35 * intensity)
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius * 0.38, hotspot);
    } else if (halfCircle) {
      final domeHotspot = Paint()
        ..color = Colors.white.withOpacity(0.20 * intensity)
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(center.translate(0, -radius * 0.40), radius * 0.30, domeHotspot);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BottomGlowPainter old) => old.intensity != intensity;
}
