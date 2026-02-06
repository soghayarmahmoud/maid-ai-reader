import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'reading_progress_model.g.dart';

@HiveType(typeId: 2)
class ReadingProgressModel extends HiveObject {
  @HiveField(0)
  late String pdfPath;

  @HiveField(1)
  late int currentPage;

  @HiveField(2)
  late int totalPages;

  @HiveField(3)
  late DateTime lastOpened;

  @HiveField(4)
  late double zoomLevel;

  @HiveField(5)
  late double scrollOffset;

  @HiveField(6)
  String? fileName;

  ReadingProgressModel({
    required this.pdfPath,
    required this.currentPage,
    required this.totalPages,
    required this.lastOpened,
    this.zoomLevel = 1.0,
    this.scrollOffset = 0.0,
    this.fileName,
  });

  // Calculate reading progress percentage
  double get progressPercentage {
    if (totalPages == 0) return 0.0;
    return (currentPage / totalPages) * 100;
  }

  // Check if book is finished
  bool get isFinished => currentPage >= totalPages;

  // Update progress
  void updateProgress({
    int? page,
    double? zoom,
    double? offset,
  }) {
    if (page != null) currentPage = page;
    if (zoom != null) zoomLevel = zoom;
    if (offset != null) scrollOffset = offset;
    lastOpened = DateTime.now();
    save(); // Save to Hive
  }
}

// Repository for reading progress

class ReadingProgressRepository {
  static const String _boxName = 'reading_progress';
  late Box<ReadingProgressModel> _progressBox;

  // Public getter to check if box is initialized
  bool get isInitialized => _progressBox != null && _progressBox.isOpen;

  Future<void> initialize() async {
    try {
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ReadingProgressModelAdapter());
      }
      _progressBox = await Hive.openBox<ReadingProgressModel>(_boxName);
      print('✓ ReadingProgressRepository initialized successfully');
    } catch (e) {
      print('✗ Error initializing ReadingProgressRepository: $e');
      rethrow;
    }
  }

  // Save or update progress
  Future<void> saveProgress(ReadingProgressModel progress) async {
    if (!isInitialized) {
      await initialize();
    }
    await _progressBox.put(progress.pdfPath, progress);
  }

  // Get progress for a PDF
  ReadingProgressModel? getProgress(String pdfPath) {
    if (!isInitialized) {
      return null;
    }
    return _progressBox.get(pdfPath);
  }

  // Get all recent files (sorted by last opened)
  List<ReadingProgressModel> getRecentFiles({int limit = 10}) {
    if (!isInitialized) {
      return [];
    }
    final allProgress = _progressBox.values.toList();
    allProgress.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    return limit > 0 ? allProgress.take(limit).toList() : allProgress;
  }

  // Delete progress
  Future<void> deleteProgress(String pdfPath) async {
    if (!isInitialized) {
      await initialize();
    }
    await _progressBox.delete(pdfPath);
  }

  // Clear all progress
  Future<void> clearAll() async {
    if (!isInitialized) {
      await initialize();
    }
    await _progressBox.clear();
  }

  void dispose() {
    if (isInitialized) {
      _progressBox.close();
    }
  }
}
