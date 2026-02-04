import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Service to handle storage permissions for PDF file access
class PermissionService {
  /// Check if storage permission is granted
  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need different permissions
      final sdkInt = await _getAndroidSdkVersion();

      if (sdkInt >= 33) {
        // Android 13+ uses granular media permissions
        // For PDFs, we don't need media permissions - file_picker handles it
        return true;
      } else if (sdkInt >= 30) {
        // Android 11-12 uses scoped storage
        // file_picker handles this, but we can check manage external storage
        final status = await Permission.manageExternalStorage.status;
        return status.isGranted || await Permission.storage.status.isGranted;
      } else {
        // Android 10 and below
        return await Permission.storage.status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't require explicit storage permission for file picker
      return true;
    }
    return true;
  }

  /// Request storage permission
  Future<PermissionResult> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();

      if (sdkInt >= 33) {
        // Android 13+ - file_picker handles permissions
        return PermissionResult.granted;
      } else if (sdkInt >= 30) {
        // Android 11-12 - request manage external storage
        var status = await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          return PermissionResult.granted;
        }

        // Fallback to regular storage
        status = await Permission.storage.request();
        if (status.isGranted) {
          return PermissionResult.granted;
        } else if (status.isPermanentlyDenied) {
          return PermissionResult.permanentlyDenied;
        }
        return PermissionResult.denied;
      } else {
        // Android 10 and below
        final status = await Permission.storage.request();
        if (status.isGranted) {
          return PermissionResult.granted;
        } else if (status.isPermanentlyDenied) {
          return PermissionResult.permanentlyDenied;
        }
        return PermissionResult.denied;
      }
    } else if (Platform.isIOS) {
      // iOS - file_picker handles permissions
      return PermissionResult.granted;
    }
    return PermissionResult.granted;
  }

  /// Open app settings for manual permission grant
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get Android SDK version
  Future<int> _getAndroidSdkVersion() async {
    try {
      // This is a simplified check - in production, use device_info_plus
      // For now, assume Android 11+ for modern devices
      return 30;
    } catch (e) {
      return 29; // Fallback to Android 10
    }
  }
}

/// Result of a permission request
enum PermissionResult {
  /// Permission was granted
  granted,

  /// Permission was denied (can ask again)
  denied,

  /// Permission was permanently denied (must go to settings)
  permanentlyDenied,
}
