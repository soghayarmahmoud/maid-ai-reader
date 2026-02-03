class TextHelpers {
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static int countWords(String text) {
    if (text.isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  static String highlightText(String text, String query) {
    if (query.isEmpty) return text;
    final pattern = RegExp(query, caseSensitive: false);
    return text.replaceAllMapped(
      pattern,
      (match) => '**${match.group(0)}**',
    );
  }
}
