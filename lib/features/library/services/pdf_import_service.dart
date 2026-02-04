import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../core/utils/permissions.dart';
import '../data/models/reading_progress_model.dart';

/// Service to handle PDF import, validation, and metadata storage
class PdfImportService {
  final PermissionService _permissionService = PermissionService();
  late ReadingProgressRepository _progressRepository;
  bool _isInitialized = false;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _progressRepository = ReadingProgressRepository();
    await _progressRepository.initialize();
    _isInitialized = true;
  }

  /// Import a PDF file from the device
  /// Returns [PdfImportResult] with success status and file/error info
  Future<PdfImportResult> importPdf() async {
    await initialize();

    // Check and request permissions
    final permissionResult = await _permissionService.requestStoragePermission();

    if (permissionResult == PermissionResult.permanentlyDenied) {
      return PdfImportResult.failure(
        error: PdfImportError.permissionDenied,
        message:
            'Storage permission permanently denied. Please enable it in app settings.',
      );
    }

    if (permissionResult == PermissionResult.denied) {
      return PdfImportResult.failure(
        error: PdfImportError.permissionDenied,
        message: 'Storage permission is required to access PDF files.',
      );
    }

    try {
      // Pick PDF file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: false, // Don't load file data into memory
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        return PdfImportResult.failure(
          error: PdfImportError.cancelled,
          message: 'File selection cancelled.',
        );
      }

      final pickedFile = result.files.first;

      if (pickedFile.path == null) {
        return PdfImportResult.failure(
          error: PdfImportError.invalidFile,
          message: 'Could not access the selected file.',
        );
      }

      final file = File(pickedFile.path!);

      // Validate the PDF file
      final validationResult = await _validatePdfFile(file);
      if (!validationResult.isValid) {
        return PdfImportResult.failure(
          error: validationResult.error!,
          message: validationResult.message!,
        );
      }

      // Save metadata
      await _saveFileMetadata(file, pickedFile.name);

      return PdfImportResult.success(
        file: file,
        fileName: pickedFile.name,
        fileSize: pickedFile.size,
      );
    } on Exception catch (e) {
      return PdfImportResult.failure(
        error: PdfImportError.unknown,
        message: 'Failed to import PDF: ${e.toString()}',
      );
    }
  }

  /// Import multiple PDF files
  Future<List<PdfImportResult>> importMultiplePdfs() async {
    await initialize();

    // Check permissions
    final permissionResult = await _permissionService.requestStoragePermission();

    if (permissionResult != PermissionResult.granted) {
      return [
        PdfImportResult.failure(
          error: PdfImportError.permissionDenied,
          message: 'Storage permission is required.',
        )
      ];
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return [
          PdfImportResult.failure(
            error: PdfImportError.cancelled,
            message: 'File selection cancelled.',
          )
        ];
      }

      final results = <PdfImportResult>[];

      for (final pickedFile in result.files) {
        if (pickedFile.path == null) {
          results.add(PdfImportResult.failure(
            error: PdfImportError.invalidFile,
            message: 'Could not access file: ${pickedFile.name}',
          ));
          continue;
        }

        final file = File(pickedFile.path!);
        final validationResult = await _validatePdfFile(file);

        if (!validationResult.isValid) {
          results.add(PdfImportResult.failure(
            error: validationResult.error!,
            message: '${pickedFile.name}: ${validationResult.message}',
          ));
          continue;
        }

        await _saveFileMetadata(file, pickedFile.name);

        results.add(PdfImportResult.success(
          file: file,
          fileName: pickedFile.name,
          fileSize: pickedFile.size,
        ));
      }

      return results;
    } on Exception catch (e) {
      return [
        PdfImportResult.failure(
          error: PdfImportError.unknown,
          message: 'Failed to import PDFs: ${e.toString()}',
        )
      ];
    }
  }

  /// Validate a PDF file
  Future<PdfValidationResult> _validatePdfFile(File file) async {
    // Check if file exists
    if (!await file.exists()) {
      return PdfValidationResult(
        isValid: false,
        error: PdfImportError.fileNotFound,
        message: 'File does not exist.',
      );
    }

    // Check file size (reject if too small or too large)
    final fileSize = await file.length();

    if (fileSize < 100) {
      return PdfValidationResult(
        isValid: false,
        error: PdfImportError.invalidFile,
        message: 'File is too small to be a valid PDF.',
      );
    }

    // 500MB limit for large documents
    if (fileSize > 500 * 1024 * 1024) {
      return PdfValidationResult(
        isValid: false,
        error: PdfImportError.fileTooLarge,
        message: 'File is too large. Maximum size is 500MB.',
      );
    }

    // Validate PDF header (magic bytes)
    try {
      final bytes = await file.openRead(0, 8).first;
      final header = String.fromCharCodes(bytes.take(5));

      if (!header.startsWith('%PDF-')) {
        return PdfValidationResult(
          isValid: false,
          error: PdfImportError.invalidFile,
          message: 'File is not a valid PDF document.',
        );
      }
    } catch (e) {
      return PdfValidationResult(
        isValid: false,
        error: PdfImportError.invalidFile,
        message: 'Could not read file header.',
      );
    }

    return PdfValidationResult(isValid: true);
  }

  /// Save file metadata to local storage
  Future<void> _saveFileMetadata(File file, String fileName) async {
    final progress = ReadingProgressModel(
      pdfPath: file.path,
      currentPage: 1,
      totalPages: 0, // Will be updated when document is loaded
      lastOpened: DateTime.now(),
      fileName: fileName,
    );

    await _progressRepository.saveProgress(progress);
  }

  /// Get recently imported files
  List<ImportedPdfInfo> getRecentFiles({int limit = 20}) {
    if (!_isInitialized) return [];

    final progressList = _progressRepository.getRecentFiles(limit: limit);

    return progressList
        .where((p) => File(p.pdfPath).existsSync())
        .map((p) => ImportedPdfInfo(
              filePath: p.pdfPath,
              fileName:
                  p.fileName ?? p.pdfPath.split(Platform.pathSeparator).last,
              lastOpened: p.lastOpened,
              currentPage: p.currentPage,
              totalPages: p.totalPages,
              progressPercentage: p.progressPercentage,
            ))
        .toList();
  }

  /// Delete a file from the import history
  Future<void> removeFromHistory(String filePath) async {
    await initialize();
    await _progressRepository.deleteProgress(filePath);
  }

  /// Clear all import history
  Future<void> clearHistory() async {
    await initialize();
    await _progressRepository.clearAll();
  }
}

/// Result of a PDF import operation
class PdfImportResult {
  final bool isSuccess;
  final File? file;
  final String? fileName;
  final int? fileSize;
  final PdfImportError? error;
  final String? message;

  PdfImportResult._({
    required this.isSuccess,
    this.file,
    this.fileName,
    this.fileSize,
    this.error,
    this.message,
  });

  factory PdfImportResult.success({
    required File file,
    required String fileName,
    required int fileSize,
  }) {
    return PdfImportResult._(
      isSuccess: true,
      file: file,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  factory PdfImportResult.failure({
    required PdfImportError error,
    required String message,
  }) {
    return PdfImportResult._(
      isSuccess: false,
      error: error,
      message: message,
    );
  }
}

/// Result of PDF validation
class PdfValidationResult {
  final bool isValid;
  final PdfImportError? error;
  final String? message;

  PdfValidationResult({
    required this.isValid,
    this.error,
    this.message,
  });
}

/// Errors that can occur during PDF import
enum PdfImportError {
  /// User cancelled file selection
  cancelled,

  /// Storage permission was denied
  permissionDenied,

  /// File was not found
  fileNotFound,

  /// File is not a valid PDF
  invalidFile,

  /// File is too large
  fileTooLarge,

  /// File is corrupted
  corrupted,

  /// Unknown error
  unknown,
}

/// Information about an imported PDF
class ImportedPdfInfo {
  final String filePath;
  final String fileName;
  final DateTime lastOpened;
  final int currentPage;
  final int totalPages;
  final double progressPercentage;

  ImportedPdfInfo({
    required this.filePath,
    required this.fileName,
    required this.lastOpened,
    required this.currentPage,
    required this.totalPages,
    required this.progressPercentage,
  });

  /// Get a human-readable time since last opened
  String get lastOpenedText {
    final now = DateTime.now();
    final difference = now.difference(lastOpened);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
