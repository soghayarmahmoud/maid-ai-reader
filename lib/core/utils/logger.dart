import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('$tagPrefix$message');
    }
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('❌ $tagPrefix$message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('ℹ️ $tagPrefix$message');
    }
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('⚠️ $tagPrefix$message');
    }
  }
}
