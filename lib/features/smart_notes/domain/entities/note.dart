class Note {
  final String id;
  final String title;
  final String content;
  final String pdfPath;
  final int pageNumber;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.pdfPath,
    required this.pageNumber,
    required this.createdAt,
  });
}
