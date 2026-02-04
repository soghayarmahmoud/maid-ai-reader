// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingProgressModelAdapter extends TypeAdapter<ReadingProgressModel> {
  @override
  final int typeId = 2;

  @override
  ReadingProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingProgressModel(
      pdfPath: fields[0] as String,
      currentPage: fields[1] as int,
      totalPages: fields[2] as int,
      lastOpened: fields[3] as DateTime,
      zoomLevel: fields[4] as double? ?? 1.0,
      scrollOffset: fields[5] as double? ?? 0.0,
      fileName: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingProgressModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.pdfPath)
      ..writeByte(1)
      ..write(obj.currentPage)
      ..writeByte(2)
      ..write(obj.totalPages)
      ..writeByte(3)
      ..write(obj.lastOpened)
      ..writeByte(4)
      ..write(obj.zoomLevel)
      ..writeByte(5)
      ..write(obj.scrollOffset)
      ..writeByte(6)
      ..write(obj.fileName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
