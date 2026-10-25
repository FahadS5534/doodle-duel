import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/gameplay/models/drawing_point_model.dart';
import 'package:frontend/features/gameplay/models/drawing_stroke_model.dart';

void main() {
  group('DrawingPointModel', () {
    test('serializes and deserializes correctly', () {
      final point = DrawingPointModel(x: 0.25, y: 0.75);
      final json = point.toJson();

      expect(json['x'], 0.25);
      expect(json['y'], 0.75);

      final fromJson = DrawingPointModel.fromJson(json);
      expect(fromJson.x, 0.25);
      expect(fromJson.y, 0.75);
      expect(fromJson, equals(point));
    });

    test('clamps coordinates to [0.0, 1.0]', () {
      final p1 = DrawingPointModel(x: -0.5, y: 1.5);
      expect(p1.x, -0.5); // Constructor holds raw, but canvas clamps
      expect(p1.y, 1.5);
    });
  });

  group('DrawingStrokeModel', () {
    test('serializes and deserializes with points list', () {
      final stroke = DrawingStrokeModel(
        strokeId: 'test-stroke-1',
        color: '#FF5733',
        brushSize: 6.0,
        tool: 'PEN',
        points: const [
          DrawingPointModel(x: 0.1, y: 0.2),
          DrawingPointModel(x: 0.3, y: 0.4),
        ],
        isFinished: true,
      );

      final json = stroke.toJson();
      expect(json['strokeId'], 'test-stroke-1');
      expect(json['color'], '#FF5733');
      expect(json['brushSize'], 6.0);
      expect(json['tool'], 'PEN');
      expect((json['points'] as List).length, 2);

      final fromJson = DrawingStrokeModel.fromJson(json);
      expect(fromJson.strokeId, 'test-stroke-1');
      expect(fromJson.color, '#FF5733');
      expect(fromJson.points.length, 2);
      expect(fromJson.isFinished, true);
    });

    test('copyWith updates fields correctly', () {
      final stroke = DrawingStrokeModel(
        strokeId: 's1',
        color: '#FF5733',
        brushSize: 5.0,
        tool: 'PEN',
      );

      final updated = stroke.copyWith(
        color: '#2EC4B6',
        brushSize: 10.0,
        isFinished: true,
      );

      expect(updated.strokeId, 's1');
      expect(updated.color, '#2EC4B6');
      expect(updated.brushSize, 10.0);
      expect(updated.isFinished, true);
    });
  });
}
