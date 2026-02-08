// ignore_for_file: deprecated_member_use

import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'annotation_model.g.dart';

@HiveType(typeId: 1)
class AnnotationModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String pdfPath;

  @HiveField(2)
  late int pageNumber;

  @HiveField(3)
  late String type; // highlight, underline, strikeout, drawing, text, comment

  @HiveField(4)
  late int color; // Color value

  @HiveField(5)
  late double x;

  @HiveField(6)
  late double y;

  @HiveField(7)
  late double width;

  @HiveField(8)
  late double height;

  @HiveField(9)
  late DateTime createdAt;

  @HiveField(10)
  String? text; // For comment annotations

  @HiveField(11)
  List<Map<String, double>>? drawingPoints; // For free-form drawing

  AnnotationModel({
    required this.id,
    required this.pdfPath,
    required this.pageNumber,
    required this.type,
    required this.color,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.createdAt,
    this.text,
    this.drawingPoints,
  });

  // Convert to entity
  Annotation toEntity() {
    return Annotation(
      id: id,
      pdfPath: pdfPath,
      pageNumber: pageNumber,
      type: AnnotationType.values.firstWhere(
        (t) => t.toString() == 'AnnotationType.$type',
        orElse: () => AnnotationType.highlight,
      ),
      color: Color(color),
      x: x,
      y: y,
      width: width,
      height: height,
      createdAt: createdAt,
      text: text,
    );
  }

  // Create from entity
  factory AnnotationModel.fromEntity(Annotation annotation) {
    return AnnotationModel(
      id: annotation.id,
      pdfPath: annotation.pdfPath,
      pageNumber: annotation.pageNumber,
      type: annotation.type.toString().split('.').last,
      color: annotation.color.value,
      x: annotation.x,
      y: annotation.y,
      width: annotation.width,
      height: annotation.height,
      createdAt: annotation.createdAt,
      text: annotation.text,
    );
  }
}

// Annotation entity (from domain layer)

class Annotation {
  final String id;
  final String pdfPath;
  final int pageNumber;
  final AnnotationType type;
  final Color color;
  final double x;
  final double y;
  final double width;
  final double height;
  final DateTime createdAt;
  final String? text;

  Annotation({
    required this.id,
    required this.pdfPath,
    required this.pageNumber,
    required this.type,
    required this.color,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.createdAt,
    this.text,
  });
}

enum AnnotationType {
  highlight,
  underline,
  strikeout,
  drawing,
  text,
  comment,
  arrow,
  rectangle,
  circle,
}
