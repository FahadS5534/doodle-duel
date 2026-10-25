import 'package:equatable/equatable.dart';

class DrawingPointModel extends Equatable {
  final double x;
  final double y;

  const DrawingPointModel({required this.x, required this.y});

  factory DrawingPointModel.fromJson(Map<String, dynamic> json) {
    return DrawingPointModel(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
  };

  @override
  List<Object?> get props => [x, y];
}
