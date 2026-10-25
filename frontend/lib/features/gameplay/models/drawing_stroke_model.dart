import 'package:equatable/equatable.dart';
import 'drawing_point_model.dart';

class DrawingStrokeModel extends Equatable {
  final String strokeId;
  final String color;
  final double brushSize;
  final String tool; // PEN, BRUSH, GLOW, FILL, ERASER
  final List<DrawingPointModel> points;
  final bool isFinished;

  const DrawingStrokeModel({
    required this.strokeId,
    this.color = '#FF5733',
    this.brushSize = 4.0,
    this.tool = 'PEN',
    this.points = const [],
    this.isFinished = false,
  });

  DrawingStrokeModel copyWith({
    String? strokeId,
    String? color,
    double? brushSize,
    String? tool,
    List<DrawingPointModel>? points,
    bool? isFinished,
  }) {
    return DrawingStrokeModel(
      strokeId: strokeId ?? this.strokeId,
      color: color ?? this.color,
      brushSize: brushSize ?? this.brushSize,
      tool: tool ?? this.tool,
      points: points ?? this.points,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  factory DrawingStrokeModel.fromJson(Map<String, dynamic> json) {
    var rawPoints = json['points'];
    List<DrawingPointModel> pointList = [];
    if (rawPoints is List) {
      pointList = rawPoints
          .map((p) => DrawingPointModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return DrawingStrokeModel(
      strokeId: json['strokeId']?.toString() ?? '',
      color: json['color']?.toString() ?? '#FF5733',
      brushSize: (json['brushSize'] as num?)?.toDouble() ?? 4.0,
      tool: json['tool']?.toString() ?? 'PEN',
      points: pointList,
      isFinished: json['isFinished'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'strokeId': strokeId,
    'color': color,
    'brushSize': brushSize,
    'tool': tool,
    'points': points.map((p) => p.toJson()).toList(),
    'isFinished': isFinished,
  };

  @override
  List<Object?> get props => [
    strokeId,
    color,
    brushSize,
    tool,
    points,
    isFinished,
  ];
}
