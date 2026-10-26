import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class LocationBadge extends StatelessWidget {
  final double size;

  const LocationBadge({
    super.key,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.65,
        height: size * 0.65,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const CustomLocationPin(
          size: 38,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Custom painter for the delicate luxury outline location pin
class CustomLocationPin extends StatelessWidget {
  final double size;
  final Color color;

  const CustomLocationPin({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.3),
      painter: _LocationPinPainter(color: color),
    );
  }
}

class _LocationPinPainter extends CustomPainter {
  final Color color;

  _LocationPinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final width = size.width;
    final height = size.height;
    final radius = width / 2;

    // Pin head and tip path
    final path = Path();
    // Start at bottom tip
    path.moveTo(radius, height);
    // Left curve up to the circle head
    path.cubicTo(
      radius * 0.2, height * 0.65,
      0, height * 0.45,
      0, radius,
    );
    // Top circle arc
    path.arcTo(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      3.14159,
      3.14159,
      false,
    );
    // Right curve down to the bottom tip
    path.cubicTo(
      width, height * 0.45,
      radius * 1.8, height * 0.65,
      radius, height,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Inner circle dot
    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawCircle(Offset(radius, radius * 0.95), radius * 0.35, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _LocationPinPainter oldDelegate) =>
      oldDelegate.color != color;
}
