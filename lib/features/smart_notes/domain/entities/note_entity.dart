import 'dart:convert';

/// Represents a note linked to a PDF document
class NoteEntity {
  /// Unique identifier for the note
  final String id;

  /// The note content/text
  final String content;

  /// The selected text from the PDF that this note is about
  final String? selectedText;

  /// Path or identifier of the PDF file
  final String pdfPath;

  /// Page number where the note was created (1-based)
  final int pageNumber;

  /// Position on the page (for highlighting)
  final NotePosition? position;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last modification timestamp
  final DateTime updatedAt;

  /// Optional title for the note
  final String? title;

  /// Tags for organization
  final List<String> tags;

  /// Color for the note highlight
  final String? highlightColor;

  /// Whether the note is pinned
  final bool isPinned;

  const NoteEntity({
    required this.id,
    required this.content,
    this.selectedText,
    required this.pdfPath,
    required this.pageNumber,
    this.position,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.tags = const [],
    this.highlightColor,
    this.isPinned = false,
  });

  /// Create a new note with auto-generated ID and timestamps
  factory NoteEntity.create({
    required String content,
    String? selectedText,
    required String pdfPath,
    required int pageNumber,
    NotePosition? position,
    String? title,
    List<String> tags = const [],
    String? highlightColor,
  }) {
    final now = DateTime.now();
    return NoteEntity(
      id: '${now.millisecondsSinceEpoch}_${pdfPath.hashCode}',
      content: content,
      selectedText: selectedText,
      pdfPath: pdfPath,
      pageNumber: pageNumber,
      position: position,
      createdAt: now,
      updatedAt: now,
      title: title,
      tags: tags,
      highlightColor: highlightColor,
    );
  }

  /// Create a copy with updated fields
  NoteEntity copyWith({
    String? id,
    String? content,
    String? selectedText,
    String? pdfPath,
    int? pageNumber,
    NotePosition? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    List<String>? tags,
    String? highlightColor,
    bool? isPinned,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      selectedText: selectedText ?? this.selectedText,
      pdfPath: pdfPath ?? this.pdfPath,
      pageNumber: pageNumber ?? this.pageNumber,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      title: title ?? this.title,
      tags: tags ?? this.tags,
      highlightColor: highlightColor ?? this.highlightColor,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'selectedText': selectedText,
      'pdfPath': pdfPath,
      'pageNumber': pageNumber,
      'position': position?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'title': title,
      'tags': tags,
      'highlightColor': highlightColor,
      'isPinned': isPinned,
    };
  }

  /// Create from JSON
  factory NoteEntity.fromJson(Map<String, dynamic> json) {
    return NoteEntity(
      id: json['id'] as String,
      content: json['content'] as String,
      selectedText: json['selectedText'] as String?,
      pdfPath: json['pdfPath'] as String,
      pageNumber: json['pageNumber'] as int,
      position: json['position'] != null
          ? NotePosition.fromJson(json['position'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      highlightColor: json['highlightColor'] as String?,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  /// Serialize to string for storage
  String serialize() => jsonEncode(toJson());

  /// Deserialize from string
  factory NoteEntity.deserialize(String data) {
    return NoteEntity.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  /// Get PDF filename from path
  String get pdfFileName {
    final parts = pdfPath.split(RegExp(r'[/\\]'));
    return parts.isNotEmpty ? parts.last : pdfPath;
  }

  /// Get a preview of the content (first 100 chars)
  String get contentPreview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NoteEntity(id: $id, page: $pageNumber, pdf: $pdfFileName)';
}

/// Position information for a note on a PDF page
class NotePosition {
  /// X coordinate (0-1 normalized)
  final double x;

  /// Y coordinate (0-1 normalized)
  final double y;

  /// Width of selection (0-1 normalized)
  final double? width;

  /// Height of selection (0-1 normalized)
  final double? height;

  /// Start character index in page text
  final int? startIndex;

  /// End character index in page text
  final int? endIndex;

  const NotePosition({
    required this.x,
    required this.y,
    this.width,
    this.height,
    this.startIndex,
    this.endIndex,
  });

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'startIndex': startIndex,
        'endIndex': endIndex,
      };

  factory NotePosition.fromJson(Map<String, dynamic> json) {
    return NotePosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      startIndex: json['startIndex'] as int?,
      endIndex: json['endIndex'] as int?,
    );
  }
}
