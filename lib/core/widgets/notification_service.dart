import 'package:flutter/material.dart';

enum NotificationType { success, error, warning, info }

/// Helper class for showing modern notifications throughout the app
class NotificationHelper {
  static void show(
    BuildContext context,
    String message, {
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    Color color;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        color = const Color(0xFF2ECC71);
        icon = Icons.check_circle_rounded;
        break;
      case NotificationType.error:
        color = const Color(0xFFE74C3C);
        icon = Icons.error_rounded;
        break;
      case NotificationType.warning:
        color = const Color(0xFFF39C12);
        icon = Icons.warning_rounded;
        break;
      case NotificationType.info:
        color = const Color(0xFF3498DB);
        icon = Icons.info_rounded;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onAction != null && actionLabel != null)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message, type: NotificationType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: NotificationType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message, type: NotificationType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: NotificationType.info);
  }
}
