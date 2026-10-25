import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/gameplay/blocs/drawing_cubit.dart';
import 'package:frontend/features/gameplay/blocs/game_bloc.dart';
import 'package:frontend/features/gameplay/models/drawing_point_model.dart';

void main() {
  group('DrawingCubit (isLocal: true - Solo Warm-up Mode)', () {
    test('initializes with default pen and color', () {
      final cubit = DrawingCubit(roomId: 'local-practice', isLocal: true);
      expect(cubit.state.selectedTool, 'PEN');
      expect(cubit.state.selectedColor, '#FF5733');
      expect(cubit.state.strokes.isEmpty, true);
      expect(cubit.state.canUndo, false);
      expect(cubit.state.canRedo, false);
    });

    test('adds points, finishes stroke, and supports local undo/redo', () {
      final cubit = DrawingCubit(roomId: 'local-practice', isLocal: true);

      // Add points
      cubit.onPointAdded(const DrawingPointModel(x: 0.1, y: 0.2));
      expect(cubit.state.activeStroke, isNotNull);
      expect(cubit.state.activeStroke!.points.length, 1);

      cubit.onPointAdded(const DrawingPointModel(x: 0.2, y: 0.3));
      expect(cubit.state.activeStroke!.points.length, 2);

      // Finish stroke
      cubit.onStrokeFinished();
      expect(cubit.state.activeStroke, isNull);
      expect(cubit.state.strokes.length, 1);
      expect(cubit.state.strokes.first.points.length, 2);
      expect(cubit.state.canUndo, true);

      // Undo
      cubit.undo();
      expect(cubit.state.strokes.isEmpty, true);
      expect(cubit.state.canUndo, false);
      expect(cubit.state.canRedo, true);

      // Redo
      cubit.redo();
      expect(cubit.state.strokes.length, 1);
      expect(cubit.state.canUndo, true);
      expect(cubit.state.canRedo, false);

      // Clear
      cubit.clearCanvas();
      expect(cubit.state.strokes.isEmpty, true);
      expect(cubit.state.canUndo, false);
    });

    test('switches color, brush size, and tools', () {
      final cubit = DrawingCubit(roomId: 'local-practice', isLocal: true);
      cubit.setColor('#2EC4B6');
      expect(cubit.state.selectedColor, '#2EC4B6');

      cubit.setBrushSize(14.0);
      expect(cubit.state.selectedBrushSize, 14.0);

      cubit.setTool('GLOW');
      expect(cubit.state.selectedTool, 'GLOW');

      cubit.setTool('ERASER');
      expect(cubit.state.selectedTool, 'ERASER');
    });
  });

  group('GameState Drawer Authority Logic', () {
    test('isDrawer is true when secretWord is non-null', () {
      const state = GameState(
        drawerId: 'user-1',
        currentUserId: 'user-2',
        secretWord: 'Pizza',
      );
      expect(state.isDrawer, isTrue);
    });

    test('isDrawer is true when drawerId matches currentUserId (case-insensitive & trimmed)', () {
      const state = GameState(
        drawerId: '  3B0E5D7A-1234-ABCD  ',
        currentUserId: '3b0e5d7a-1234-abcd',
      );
      expect(state.isDrawer, isTrue);
    });

    test('isDrawer is false when user is not drawer and secretWord is null', () {
      const state = GameState(
        drawerId: 'drawer-uuid',
        currentUserId: 'guesser-uuid',
        secretWord: null,
      );
      expect(state.isDrawer, isFalse);
    });
  });
}
