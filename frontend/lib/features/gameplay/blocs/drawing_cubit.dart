import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/websocket/stomp_service.dart';
import '../models/drawing_point_model.dart';
import '../models/drawing_stroke_model.dart';

class DrawingState extends Equatable {
  final List<DrawingStrokeModel> strokes;
  final DrawingStrokeModel? activeStroke;
  final String selectedColor;
  final double selectedBrushSize;
  final String selectedTool; // PEN, BRUSH, GLOW, FILL, ERASER
  final bool canUndo;
  final bool canRedo;

  const DrawingState({
    this.strokes = const [],
    this.activeStroke,
    this.selectedColor = '#FF5733',
    this.selectedBrushSize = 5.0,
    this.selectedTool = 'PEN',
    this.canUndo = false,
    this.canRedo = false,
  });

  DrawingState copyWith({
    List<DrawingStrokeModel>? strokes,
    DrawingStrokeModel? activeStroke,
    bool clearActiveStroke = false,
    String? selectedColor,
    double? selectedBrushSize,
    String? selectedTool,
    bool? canUndo,
    bool? canRedo,
  }) {
    return DrawingState(
      strokes: strokes ?? this.strokes,
      activeStroke: clearActiveStroke ? null : (activeStroke ?? this.activeStroke),
      selectedColor: selectedColor ?? this.selectedColor,
      selectedBrushSize: selectedBrushSize ?? this.selectedBrushSize,
      selectedTool: selectedTool ?? this.selectedTool,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }

  @override
  List<Object?> get props => [
    strokes,
    activeStroke,
    selectedColor,
    selectedBrushSize,
    selectedTool,
    canUndo,
    canRedo,
  ];
}

class DrawingCubit extends Cubit<DrawingState> {
  final String roomId;
  final bool isLocal;
  final StompService _stompService = StompService();
  final _uuid = const Uuid();

  StreamSubscription? _drawingEventsSubscription;
  final List<DrawingStrokeModel> _redoStack = [];

  // Batching buffer for network transmission (approx 45ms)
  Timer? _batchTimer;
  final List<DrawingPointModel> _pointBuffer = [];
  String? _currentStrokeId;

  DrawingCubit({required this.roomId, this.isLocal = false}) : super(const DrawingState()) {
    if (!isLocal) {
      _drawingEventsSubscription = _stompService.drawingEvents.listen(_handleRemoteDrawingEvent);
    }
  }

  void setColor(String hex) {
    emit(state.copyWith(selectedColor: hex));
  }

  void setBrushSize(double size) {
    emit(state.copyWith(selectedBrushSize: size));
  }

  void setTool(String tool) {
    emit(state.copyWith(selectedTool: tool));
  }

  void onPointAdded(DrawingPointModel point) {
    _currentStrokeId ??= _uuid.v4();

    DrawingStrokeModel currentActive = state.activeStroke ??
        DrawingStrokeModel(
          strokeId: _currentStrokeId!,
          color: state.selectedColor,
          brushSize: state.selectedBrushSize,
          tool: state.selectedTool,
          points: const [],
          isFinished: false,
        );

    final updatedPoints = List<DrawingPointModel>.from(currentActive.points)..add(point);
    final updatedActive = currentActive.copyWith(points: updatedPoints);

    _pointBuffer.add(point);
    _scheduleBatchFlush();

    emit(state.copyWith(activeStroke: updatedActive));
  }

  void onStrokeFinished() {
    _batchTimer?.cancel();
    if (state.activeStroke != null) {
      final finishedStroke = state.activeStroke!.copyWith(isFinished: true);
      final updatedStrokes = List<DrawingStrokeModel>.from(state.strokes)..add(finishedStroke);
      _redoStack.clear();

      // Flush remaining points and mark finished over network
      _flushPoints(isFinished: true);

      emit(state.copyWith(
        strokes: updatedStrokes,
        clearActiveStroke: true,
        canUndo: true,
        canRedo: false,
      ));
    }
    _currentStrokeId = null;
    _pointBuffer.clear();
  }

  void undo() {
    if (state.strokes.isNotEmpty) {
      final updated = List<DrawingStrokeModel>.from(state.strokes);
      final removed = updated.removeLast();
      _redoStack.add(removed);

      if (!isLocal) {
        _stompService.sendDrawingUndo(roomId);
      }

      emit(state.copyWith(
        strokes: updated,
        canUndo: updated.isNotEmpty,
        canRedo: true,
      ));
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      final restored = _redoStack.removeLast();
      final updated = List<DrawingStrokeModel>.from(state.strokes)..add(restored);

      // Transmit restored stroke if online
      if (!isLocal) {
        _stompService.sendDrawingPoints(roomId, restored.toJson());
      }

      emit(state.copyWith(
        strokes: updated,
        canUndo: true,
        canRedo: _redoStack.isNotEmpty,
      ));
    }
  }

  void clearCanvas() {
    if (!isLocal) {
      _stompService.sendDrawingClear(roomId);
    }
    _redoStack.clear();
    emit(state.copyWith(
      strokes: const [],
      clearActiveStroke: true,
      canUndo: false,
      canRedo: false,
    ));
  }

  void clear() => clearCanvas();

  void loadSnapshot(List<DrawingStrokeModel> snapshot) {
    emit(state.copyWith(
      strokes: snapshot,
      canUndo: snapshot.isNotEmpty,
    ));
  }

  void _scheduleBatchFlush() {
    if (isLocal) return; // Zero latency local mode does not need network batching
    if (_pointBuffer.length >= 6) {
      _flushPoints(isFinished: false);
      return;
    }
    _batchTimer?.cancel();
    _batchTimer = Timer(const Duration(milliseconds: 45), () {
      _flushPoints(isFinished: false);
    });
  }

  void _flushPoints({required bool isFinished}) {
    if (isLocal) return;
    if (_pointBuffer.isEmpty && !isFinished) return;
    if (_currentStrokeId == null) return;

    final chunk = DrawingStrokeModel(
      strokeId: _currentStrokeId!,
      color: state.selectedColor,
      brushSize: state.selectedBrushSize,
      tool: state.selectedTool,
      points: List.from(_pointBuffer),
      isFinished: isFinished,
    );

    _stompService.sendDrawingPoints(roomId, chunk.toJson());
    _pointBuffer.clear();
  }

  void _handleRemoteDrawingEvent(Map<String, dynamic> event) {
    final type = event['eventType']?.toString();
    final payload = event['payload'];

    if (type == 'DRAWING_POINTS' && payload is Map<String, dynamic>) {
      final remoteStroke = DrawingStrokeModel.fromJson(payload);
      _mergeRemoteStroke(remoteStroke);
    } else if (type == 'DRAWING_UNDO') {
      if (state.strokes.isNotEmpty) {
        final updated = List<DrawingStrokeModel>.from(state.strokes)..removeLast();
        emit(state.copyWith(strokes: updated, canUndo: updated.isNotEmpty));
      }
    } else if (type == 'DRAWING_CLEAR') {
      emit(state.copyWith(strokes: const [], clearActiveStroke: true, canUndo: false));
    }
  }

  void _mergeRemoteStroke(DrawingStrokeModel stroke) {
    final existingIndex = state.strokes.indexWhere((s) => s.strokeId == stroke.strokeId);
    if (existingIndex != -1) {
      final existing = state.strokes[existingIndex];
      final mergedPoints = List<DrawingPointModel>.from(existing.points)..addAll(stroke.points);
      final updatedStroke = existing.copyWith(
        points: mergedPoints,
        isFinished: stroke.isFinished,
      );
      final updatedStrokes = List<DrawingStrokeModel>.from(state.strokes);
      updatedStrokes[existingIndex] = updatedStroke;
      emit(state.copyWith(strokes: updatedStrokes));
    } else {
      final updatedStrokes = List<DrawingStrokeModel>.from(state.strokes)..add(stroke);
      emit(state.copyWith(strokes: updatedStrokes, canUndo: true));
    }
  }

  @override
  Future<void> close() {
    _batchTimer?.cancel();
    _drawingEventsSubscription?.cancel();
    return super.close();
  }
}
