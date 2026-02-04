import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String content;

  @HiveField(3)
  late String pdfPath;

  @HiveField(4)
  late int pageNumber;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late DateTime updatedAt;

  @HiveField(7)
  List<String>? tags;

  @HiveField(8)
  String? summary; // AI-generated summary

  @HiveField(9)
  String? voiceNotePath; // Path to voice recording if any

  Note Model({
    required this.id,
    required this.title,
    required this.content,
    required this.pdfPath,
    required this.pageNumber,
    required this.createdAt,
    required this.updatedAt,
    this.tags,
    this.summary,
    this.voiceNotePath,
  });

  // Convert to entity
  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      pdfPath: pdfPath,
      pageNumber: pageNumber,
      createdAt: createdAt,
      tags: tags,
      summary: summary,
    );
  }

  // Create from entity
  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      pdfPath: note.pdfPath,
      pageNumber: note.pageNumber,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
      tags: note.tags,
      summary: note.summary,
    );
  }
}

// Note entity (from domain layer)
class Note {
  final String id;
  final String title;
  final String content;
  final String pdfPath;
  final int pageNumber;
  final DateTime createdAt;
  final List<String>? tags;
  final String? summary;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.pdfPath,
    required this.pageNumber,
    required this.createdAt,
    this.tags,
    this.summary,
  });
}
