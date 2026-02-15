import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  /// Request a single permission with a beautiful dialog
  static Future<bool> requestPermission(
    BuildContext context,
    Permission permission, {
    required String title,
    required String description,
    String? denyLabel,
    String? allowLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _PermissionDialog(
        title: title,
        description: description,
        permission: permission,
        denyLabel: denyLabel,
        allowLabel: allowLabel,
      ),
    );
    return result ?? false;
  }

  /// Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestPermissions(
    BuildContext context,
    List<Permission> permissions, {
    required String title,
    required String description,
  }) async {
    final result = await showDialog<Map<Permission, PermissionStatus>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _MultiplePermissionsDialog(
        title: title,
        description: description,
        permissions: permissions,
      ),
    );
    return result ?? {};
  }
}

class _PermissionDialog extends StatefulWidget {
  final String title;
  final String description;
  final Permission permission;
  final String? denyLabel;
  final String? allowLabel;

  const _PermissionDialog({
    required this.title,
    required this.description,
    required this.permission,
    this.denyLabel,
    this.allowLabel,
  });

  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C3CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.privacy_tip_rounded,
                size: 48,
                color: Color(0xFF6C3CE7),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.denyLabel ?? 'Don\'t Allow',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C3CE7),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.allowLabel ?? 'Allow',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);

    final status = await widget.permission.request();

    if (mounted) {
      setState(() => _isLoading = false);
      if (status.isGranted) {
        Navigator.pop(context, true);
      } else if (status.isDenied) {
        Navigator.pop(context, false);
      } else if (status.isDenied || status.isRestricted) {
        if (mounted) {
          _showOpenSettingsDialog();
        }
      }
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'This permission is required for the app to function properly. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
              Navigator.pop(context, false);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _MultiplePermissionsDialog extends StatefulWidget {
  final String title;
  final String description;
  final List<Permission> permissions;

  const _MultiplePermissionsDialog({
    required this.title,
    required this.description,
    required this.permissions,
  });

  @override
  State<_MultiplePermissionsDialog> createState() =>
      _MultiplePermissionsDialogState();
}

class _MultiplePermissionsDialogState
    extends State<_MultiplePermissionsDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C3CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 48,
                color: Color(0xFF6C3CE7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.pop(context, {}),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _requestPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C3CE7),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Allow',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);

    final statuses = await widget.permissions.request();

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context, statuses);
    }
  }
}
