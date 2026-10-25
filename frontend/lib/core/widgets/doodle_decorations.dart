import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AmbientDoodleBackground extends StatelessWidget {
  final Widget? child;

  const AmbientDoodleBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _DoodleCanvasPainter(),
          ),
        ),
        ?child,
      ],
    );
  }
}

class _DoodleCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft coral circle at top left
    final coralCirclePaint = Paint()
      ..color = AppColors.primaryCoral.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.12), 35, coralCirclePaint);

    // 2. Soft mint circle at upper right
    final mintCirclePaint = Paint()
      ..color = AppColors.accentMint.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.28), 50, mintCirclePaint);

    // 3. Dashed playful squiggle arc
    final squigglePaint = Paint()
      ..color = AppColors.primaryCoral.withValues(alpha: 0.18)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(30, size.height * 0.35)
      ..quadraticBezierTo(70, size.height * 0.32, 110, size.height * 0.35)
      ..quadraticBezierTo(150, size.height * 0.38, 190, size.height * 0.35);
    canvas.drawPath(path, squigglePaint);

    // 4. Yellow star sparkle
    _drawStar(canvas, Offset(size.width * 0.82, size.height * 0.16), 10, AppColors.accentYellow.withValues(alpha: 0.35));

    // 5. Mint star sparkle lower left
    _drawStar(canvas, Offset(size.width * 0.10, size.height * 0.65), 8, AppColors.accentMint.withValues(alpha: 0.25));
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      double angle = -pi / 2 + (i * 4 * pi / 5);
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
