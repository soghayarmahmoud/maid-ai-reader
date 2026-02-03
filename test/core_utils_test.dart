import 'package:flutter_test/flutter_test.dart';
import 'package:maid_ai_reader/core/utils/text_helpers.dart';

void main() {
  group('TextHelpers', () {
    test('truncate should truncate long text', () {
      const text = 'This is a very long text that needs to be truncated';
      final result = TextHelpers.truncate(text, 20);
      expect(result, 'This is a very long ...');
    });

    test('truncate should return original text if shorter than max length', () {
      const text = 'Short text';
      final result = TextHelpers.truncate(text, 20);
      expect(result, 'Short text');
    });

    test('capitalize should capitalize first letter', () {
      const text = 'hello world';
      final result = TextHelpers.capitalize(text);
      expect(result, 'Hello world');
    });

    test('countWords should count words correctly', () {
      const text = 'This is a test';
      final result = TextHelpers.countWords(text);
      expect(result, 4);
    });

    test('countWords should return 0 for empty string', () {
      const text = '';
      final result = TextHelpers.countWords(text);
      expect(result, 0);
    });
  });
}
