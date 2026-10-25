import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/drawing_cubit.dart';
import '../models/drawing_point_model.dart';
import '../models/drawing_stroke_model.dart';

typedef OnPointAdded = void Function(DrawingPointModel point);
typedef OnStrokeFinished = void Function();

class DrawingCanvas extends StatelessWidget {
  final List<DrawingStrokeModel>? strokes;
  final DrawingStrokeModel? activeStroke;
  final bool isInteractive;
  final bool isReadOnly;
  final OnPointAdded? onPointAdded;
  final OnStrokeFinished? onStrokeFinished;

  const DrawingCanvas({
    super.key,
    this.strokes,
    this.activeStroke,
    this.isInteractive = false,
    this.isReadOnly = true,
    this.onPointAdded,
    this.onStrokeFinished,
  });

  @override
  Widget build(BuildContext context) {
    // If strokes are not passed directly, obtain them from DrawingCubit in context
    List<DrawingStrokeModel> effectiveStrokes = strokes ?? const [];
    DrawingStrokeModel? effectiveActive = activeStroke;
    DrawingCubit? cubit;

    if (strokes == null) {
      try {
        final drawingState = context.watch<DrawingCubit>().state;
        effectiveStrokes = drawingState.strokes;
        effectiveActive = drawingState.activeStroke;
        cubit = context.read<DrawingCubit>();
      } catch (_) {}
    }

    final bool canInteract = isInteractive || !isReadOnly;

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        final canvasHeight = constraints.maxHeight;

        Widget canvasWidget = CustomPaint(
          size: Size(canvasWidth, canvasHeight),
          painter: _DoodlePainter(
            strokes: effectiveStrokes,
            activeStroke: effectiveActive,
          ),
        );

        if (!canInteract) {
          return canvasWidget;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            final local = details.localPosition;
            final normalized = DrawingPointModel(
              x: (local.dx / canvasWidth).clamp(0.0, 1.0),
              y: (local.dy / canvasHeight).clamp(0.0, 1.0),
            );
            if (onPointAdded != null) {
              onPointAdded!(normalized);
            } else {
              cubit?.onPointAdded(normalized);
            }
          },
          onPanUpdate: (details) {
            final local = details.localPosition;
            final normalized = DrawingPointModel(
              x: (local.dx / canvasWidth).clamp(0.0, 1.0),
              y: (local.dy / canvasHeight).clamp(0.0, 1.0),
            );
            if (onPointAdded != null) {
              onPointAdded!(normalized);
            } else {
              cubit?.onPointAdded(normalized);
            }
          },
          onPanEnd: (_) {
            if (onStrokeFinished != null) {
              onStrokeFinished!();
            } else {
              cubit?.onStrokeFinished();
            }
          },
          child: canvasWidget,
        );
      },
    );
  }
}

class _DoodlePainter extends CustomPainter {
  final List<DrawingStrokeModel> strokes;
  final DrawingStrokeModel? activeStroke;

  _DoodlePainter({
    required this.strokes,
    this.activeStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Solid white crisp canvas background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, size, stroke);
    }

    // Draw active in-progress stroke
    if (activeStroke != null) {
      _drawStroke(canvas, size, activeStroke!);
    }
  }

  void _drawStroke(Canvas canvas, Size size, DrawingStrokeModel stroke) {
    if (stroke.points.isEmpty) return;

    final color = _parseColor(stroke.color);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (stroke.tool.toUpperCase() == 'ERASER') {
      paint.color = Colors.white;
      paint.strokeWidth = stroke.brushSize * 2.2;
    } else if (stroke.tool.toUpperCase() == 'GLOW') {
      paint.color = color.withValues(alpha: 0.7);
      paint.strokeWidth = stroke.brushSize * 1.8;
      paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);
    } else {
      paint.color = color;
      paint.strokeWidth = stroke.brushSize;
    }

    if (stroke.points.length == 1) {
      final p = stroke.points[0];
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        paint.strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = Path();
    final firstPoint = stroke.points[0];
    path.moveTo(firstPoint.x * size.width, firstPoint.y * size.height);

    for (int i = 1; i < stroke.points.length; i++) {
      final prev = stroke.points[i - 1];
      final curr = stroke.points[i];
      final p0 = Offset(prev.x * size.width, prev.y * size.height);
      final p1 = Offset(curr.x * size.width, curr.y * size.height);

      // Smooth midpoint quadratic bezier
      final midPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
    }

    final lastPoint = stroke.points.last;
    path.lineTo(lastPoint.x * size.width, lastPoint.y * size.height);

    canvas.drawPath(path, paint);
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      } else if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFFFF5733);
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter oldDelegate) {
    return true;
  }
}
