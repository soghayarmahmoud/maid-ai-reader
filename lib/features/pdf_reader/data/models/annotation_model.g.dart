// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnnotationModelAdapter extends TypeAdapter<AnnotationModel> {
  @override
  final int typeId = 1;

  @override
  AnnotationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnnotationModel(
      id: fields[0] as String,
      pdfPath: fields[1] as String,
      pageNumber: fields[2] as int,
      type: fields[3] as String,
      color: fields[4] as int,
      x: fields[5] as double,
      y: fields[6] as double,
      width: fields[7] as double,
      height: fields[8] as double,
      createdAt: fields[9] as DateTime,
      text: fields[10] as String?,
      drawingPoints: (fields[11] as List? ?? [])
          .map((dynamic e) => (e as Map).cast<String, double>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, AnnotationModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pdfPath)
      ..writeByte(2)
      ..write(obj.pageNumber)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.x)
      ..writeByte(6)
      ..write(obj.y)
      ..writeByte(7)
      ..write(obj.width)
      ..writeByte(8)
      ..write(obj.height)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.text)
      ..writeByte(11)
      ..write(obj.drawingPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnotationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
