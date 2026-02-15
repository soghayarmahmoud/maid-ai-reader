# 🚀 Advanced PDF Editing & AI Search Features

## 📚 Table of Contents
- [PDF Editing Features](#pdf-editing-features)
- [Advanced Search Features](#advanced-search-features)
- [Voice Input Features](#voice-input-features)
- [Document Comparison](#document-comparison)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)

---

## 🎨 PDF Editing Features

### Service: `PdfEditorService`
**File**: [`pdf_editor_service.dart`](file:///g:/flutter_work/maid-ai-reader-main/lib/features/pdf_editor/services/pdf_editor_service.dart)

### 11 Editing Operations:

#### 1. **Insert Image** 📷
Add images to any page at specified coordinates.

```dart
final editorService = PdfEditorService();

await editorService.insertImage(
  pdfPath: '/path/to/document.pdf',
  imagePath: '/path/to/image.jpg',
  pageNumber: 0,  // First page
  x: 50,
  y: 100,
  width: 200,
  height: 150,
);
```

#### 2. **Rotate Pages** 🔄
Rotate individual pages by 90, 180, or 270 degrees.

```dart
await editorService.rotatePage(
  pdfPath: '/path/to/document.pdf',
  pageNumber: 2,
  angle: PdfPageRotateAngle.rotateAngle90,
);
```

**Angles**: `rotateAngle90`, `rotateAngle180`, `rotateAngle270`

#### 3. **Delete Pages** 🗑️
Remove unwanted pages from the document.

```dart
await editorService.deletePage(
  pdfPath: '/path/to/document.pdf',
  pageNumber: 5,
);
```

#### 4. **Reorder Pages** 🔀
Change the order of pages in the document.

```dart
// New order: [page 3, page 1, page 2, page 0]
await editorService.reorderPages(
  pdfPath: '/path/to/document.pdf',
  newOrder: [3, 1, 2, 0],
);
```

#### 5. **Merge PDFs** 📑
Combine multiple PDF files into one.

```dart
final outputPath = await editorService.mergePdfs(
  pdfPaths: [
    '/path/to/doc1.pdf',
    '/path/to/doc2.pdf',
    '/path/to/doc3.pdf',
  ],
  outputPath: '/path/to/merged.pdf',
);
```

#### 6. **Split PDF** ✂️
Split a PDF into multiple smaller files.

```dart
final splitFiles = await editorService.splitPdf(
  pdfPath: '/path/to/document.pdf',
  outputDir: '/path/to/output',
  splitPoints: [5, 10, 15],  // Split at pages 5, 10, and 15
);
// Returns: ['/output/split_1.pdf', '/output/split_2.pdf', ...]
```

#### 7. **Add Watermark** 💧
Add text watermark to all pages.

```dart
await editorService.addWatermark(
  pdfPath: '/path/to/document.pdf',
  watermarkText: 'CONFIDENTIAL',
  opacity: 0.3,  // 0.0 to 1.0
  fontSize: 48,
  color: PdfColor(128, 128, 128),  // Gray
);
```

#### 8. **Fill Form Fields** 📝
Programmatically fill PDF form fields.

```dart
await editorService.fillFormField(
  pdfPath: '/path/to/form.pdf',
  fieldName: 'customerName',
  value: 'John Doe',
);
```

#### 9. **Add Signature** ✍️
Insert digital signature image.

```dart
await editorService.addSignature(
  pdfPath: '/path/to/document.pdf',
  signatureImagePath: '/path/to/signature.png',
  pageNumber: 0,
  bounds: Rect.fromLTWH(400, 600, 150, 50),
);
```

#### 10. **Crop Pages** ✂️
Trim page margins or extract specific areas.

```dart
await editorService.cropPage(
  pdfPath: '/path/to/document.pdf',
  pageNumber: 0,
  cropBox: Rect.fromLTWH(50, 50, 400, 600),
);
```

#### 11. **Export Edited PDF** 💾
Export with optional flattening of forms and annotations.

```dart
final exportedPath = await editorService.exportPdf(
  sourcePath: '/path/to/document.pdf',
  destinationPath: '/path/to/exported.pdf',
  flatten: true,  // Flatten forms and annotations
);
```

### PDF Editor UI
**File**: [`pdf_editor_page.dart`](file:///g:/flutter_work/maid-ai-reader-main/lib/features/pdf_editor/presentation/pdf_editor_page.dart)

Beautiful interface with:
- ✅ Organized sections (Page Operations, Add Content, Document Operations)
- ✅ Document info display
- ✅ Action tiles with icons
- ✅ Dialogs for each operation

---

## 🔍 Advanced Search Features

### Service: `AdvancedSearchService`
**File**: [`advanced_search_service.dart`](file:///g:/flutter_work/maid-ai-reader-main/lib/features/pdf_reader/services/advanced_search_service.dart)

### 4 Search Types:

#### 1. **Basic Search** 🔎
Standard text search with options.

```dart
final searchService = AdvancedSearchService();

final results = await searchService.basicSearch(
  text: pdfText,
  searchTerm: 'contract',
  caseSensitive: false,
  wholeWord: true,
);
```

#### 2. **Regex Search** 🔤
Search using regular expressions.

```dart
final results = await searchService.regexSearch(
  pdfText: pdfText,
  pattern: r'\d{3}-\d{3}-\d{4}',  // Phone numbers
  caseSensitive: false,
);
```

**Common Patterns**:
- Phone: `\d{3}-\d{3}-\d{4}`
- Email: `\w+@\w+\.\w+`
- URL: `https?://\S+`
- Numbers: `\d+`

#### 3. **OCR Search** 📄
Search in scanned documents using Optical Character Recognition.

```dart
final results = await searchService.ocrSearch(
  pdfPath: '/path/to/scanned.pdf',
  searchTerm: 'invoice',
);
```

**Uses**: Google ML Kit for text recognition

#### 4. **Semantic Search** 🧠
AI-powered search that understands meaning and context.

```dart
final results = await searchService.semanticSearch(
  pdfText: pdfText,
  query: 'What are the payment terms?',
  aiSimilarityCheck: (query, chunk) async {
    // AI similarity logic
    return chunk;
  },
);
```

#### 5. **Multi-PDF Search** 📚
Search across multiple PDF files simultaneously.

```dart
final results = await searchService.searchMultiplePdfs(
  pdfPaths: [
    '/path/to/doc1.pdf',
    '/path/to/doc2.pdf',
    '/path/to/doc3.pdf',
  ],
  searchTerm: 'deadline',
  caseSensitive: false,
  wholeWord: false,
);

// Returns: Map<String, List<SearchResult>>
// Keys: PDF paths, Values: Search results
```

#### 6. **Search Bookmarks** 🔖
Save and load frequent searches.

```dart
// Save a search
await searchService.saveSearchBookmark(
  pdfPath: '/path/to/document.pdf',
  searchTerm: 'important clause',
  results: results,
);

// Load saved searches
final bookmarks = await searchService.getSavedSearches(
  '/path/to/document.pdf',
);
```

### Advanced Search Panel UI
**File**: [`advanced_search_panel.dart`](file:///g:/flutter_work/maid-ai-reader-main/lib/features/pdf_reader/presentation/widgets/advanced_search_panel.dart)

Features:
- ✅ Tabbed interface (Basic, Regex, OCR, Semantic)
- ✅ Search options (case sensitive, whole word)
- ✅ Common regex patterns chips
- ✅ Results preview with page numbers
- ✅ Result context snippets
- ✅ Tap to jump to page

---

## 🎤 Voice Input Features

### Service: `VoiceInputService`
**File**: [`voice_input_service.dart`](file:///g:/flutter_work/maid-ai-reader-main/lib/features/ai_search/services/voice_input_service.dart)

### Features:

#### 1. **Speech-to-Text** 🗣️
Convert voice to text for AI queries.

```dart
final voiceService = VoiceInputService();

// Initialize
await voiceService.initialize();

// Start listening
await voiceService.startListening(
  onResult: (text) {
    print('You said: $text');
    // Send to AI
  },
  localeId: 'en-US',
);

// Stop listening
await voiceService.stopListening();
```

#### 2. **Text-to-Speech** 🔊
Read PDF content aloud.

```dart
// Speak text
await voiceService.speak('This is the PDF content');

// Control speech
await voiceService.setSpeechRate(0.5);  // Slower
await voiceService.setVolume(1.0);      // Max volume
await voiceService.setPitch(1.0);       // Normal pitch

// Stop/Pause
await voiceService.stopSpeaking();
await voiceService.pauseSpeaking();
```

#### 3. **Voice Input Button Widget** 🎙️
Ready-to-use animated button.

```dart
VoiceInputButton(
  onResult: (text) {
    // Handle voice input
    print('Voice input: $text');
  },
)
```

Features:
- ✅ Animated pulsing effect while listening
- ✅ Auto-start/stop
- ✅ Error handling
- ✅ Visual feedback

---

## 📊 Document Comparison

### Service: `DocumentComparisonService`
**File**: [`document_comparison_service.dart`](file:///g:/flutter_work/maid-ai-reader-main/lib/features/pdf_reader/services/document_comparison_service.dart)

#### 1. **AI-Powered Document Comparison** 🤖

```dart
final comparisonService = DocumentComparisonService();

final result = await comparisonService.compareDocuments(
  doc1Path: '/path/to/original.pdf',
  doc2Path: '/path/to/revised.pdf',
  doc1Text: originalText,
  doc2Text: revisedText,
);

print('Summary: ${result.summary}');
print('Differences: ${result.differences}');
print('Similarities: ${result.similarities}');
print('Change %: ${result.changePercentage}');
```

**Returns**:
- Summary of changes
- List of differences
- List of similarities
- Added content
- Removed content
- Change percentage

#### 2. **Context-Aware Scrolling Suggestions** 🎯

AI suggests where to navigate next based on current content.

```dart
final suggestions = await comparisonService.getScrollSuggestions(
  currentPageText: 'Current page content...',
  currentPage: 5,
  totalPages: 50,
);

for (var suggestion in suggestions) {
  print('${suggestion.description} -> Page ${suggestion.targetPage}');
  print('Relevance: ${suggestion.relevanceScore}');
}
```

---

## 💡 Usage Examples

### Example 1: Complete PDF Editing Workflow

```dart
final editor = PdfEditorService();

// 1. Add watermark
await editor.addWatermark(
  pdfPath: '/path/to/contract.pdf',
  watermarkText: 'DRAFT',
  opacity: 0.2,
);

// 2. Add signature
await editor.addSignature(
  pdfPath: '/path/to/contract.pdf',
  signatureImagePath: '/path/to/signature.png',
  pageNumber: 4,
  bounds: Rect.fromLTWH(400, 650, 150, 40),
);

// 3. Export final version
final finalPath = await editor.exportPdf(
  sourcePath: '/path/to/contract.pdf',
  destinationPath: '/path/to/signed_contract.pdf',
  flatten: true,
);
```

### Example 2: Advanced Search Workflow

```dart
final search = AdvancedSearchService();

// 1. Search with regex for dates
final dateResults = await search.regexSearch(
  pdfText: pdfText,
  pattern: r'\d{2}/\d{2}/\d{4}',
);

// 2. Save important search
await search.saveSearchBookmark(
  pdfPath: pdfPath,
  searchTerm: 'payment deadline',
  results: dateResults,
);

// 3. Later, load saved searches
final bookmarks = await search.getSavedSearches(pdfPath);
```

### Example 3: Voice-Enabled AI Chat

```dart
final voiceService = VoiceInputService();
final aiService = GeminiAiService();

// Listen for voice query
await voiceService.startListening(
  onResult: (voiceText) async {
    // Send to AI
    final aiResponse = await aiService.sendChatMessage(voiceText);
    
    // Read response aloud
    await voiceService.speak(aiResponse);
  },
);
```

---

## 📋 API Reference

### PdfEditorService Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `insertImage()` | pdfPath, imagePath, pageNumber, x, y, width, height | `Future<bool>` | Insert image at position |
| `rotatePage()` | pdfPath, pageNumber, angle | `Future<bool>` | Rotate page |
| `deletePage()` | pdfPath, pageNumber | `Future<bool>` | Delete page |
| `reorderPages()` | pdfPath, newOrder | `Future<bool>` | Reorder pages |
| `mergePdfs()` | pdfPaths, outputPath | `Future<String?>` | Merge PDFs |
| `splitPdf()` | pdfPath, outputDir, splitPoints | `Future<List<String>>` | Split PDF |
| `addWatermark()` | pdfPath, watermarkText, opacity, fontSize, color | `Future<bool>` | Add watermark |
| `fillFormField()` | pdfPath, fieldName, value | `Future<bool>` | Fill form field |
| `addSignature()` | pdfPath, signatureImagePath, pageNumber, bounds | `Future<bool>` | Add signature |
| `cropPage()` | pdfPath, pageNumber, cropBox | `Future<bool>` | Crop page |
| `exportPdf()` | sourcePath, destinationPath, flatten | `Future<String?>` | Export PDF |
| `getPdfInfo()` | pdfPath | `Future<PdfInfo?>` | Get PDF metadata |

### AdvancedSearchService Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `basicSearch()` | text, searchTerm, caseSensitive, wholeWord | `Future<List<SearchResult>>` | Basic search |
| `regexSearch()` | pdfText, pattern, caseSensitive | `Future<List<SearchResult>>` | Regex search |
| `ocrSearch()` | pdfPath, searchTerm | `Future<List<SearchResult>>` | OCR search |
| `semanticSearch()` | pdfText, query, aiSimilarityCheck | `Future<List<SearchResult>>` | Semantic search |
| `searchMultiplePdfs()` | pdfPaths, searchTerm, options | `Future<Map<String, List<SearchResult>>>` | Multi-PDF search |
| `saveSearchBookmark()` | pdfPath, searchTerm, results | `Future<void>` | Save bookmark |
| `getSavedSearches()` | pdfPath | `Future<List<SearchBookmark>>` | Load bookmarks |

### VoiceInputService Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `initialize()` | - | `Future<bool>` | Initialize service |
| `startListening()` | onResult, localeId | `Future<void>` | Start listening |
| `stopListening()` | - | `Future<void>` | Stop listening |
| `speak()` | text | `Future<void>` | Text-to-speech |
| `setSpeechRate()` | rate | `Future<void>` | Set TTS speed |
| `setVolume()` | volume | `Future<void>` | Set volume |
| `setPitch()` | pitch | `Future<void>` | Set pitch |

---

## 🚀 Quick Start

1. **Add dependencies** (already in pubspec.yaml):
   - `syncfusion_flutter_pdf`
   - `google_ml_kit`
   - `speech_to_text`
   - `flutter_tts`
   - `pdf_render`

2. **Initialize services**:
   ```dart
   final editor = PdfEditorService();
   final search = AdvancedSearchService();
   final voice = VoiceInputService();
   ```

3. **Use in your app**:
   ```dart
   // Navigate to PDF editor
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => PdfEditorPage(pdfPath: '/path/to/pdf'),
     ),
   );
   
   // Show advanced search
   showModalBottomSheet(
     context: context,
     builder: (context) => AdvancedSearchPanel(
       pdfPath: pdfPath,
       pdfText: pdfText,
     ),
   );
   ```

---

## 🎯 Features Summary

### PDF Editing (11 features) ✅
- Insert images
- Rotate pages
- Delete pages
- Reorder pages
- Merge PDFs
- Split PDFs
- Add watermarks
- Fill forms
- Add signatures
- Crop pages
- Export with flatten

### Search (6 types) ✅
- Basic search
- Regex search
- OCR search
- Semantic AI search
- Multi-PDF search
- Search bookmarks

### Voice (2 features) ✅
- Speech-to-text
- Text-to-speech

### AI Features (2 features) ✅
- Document comparison
- Scroll suggestions

**Total: 21 Advanced Features Implemented!** 🎉

---

## 📝 Notes

- All services use `async/await` for better performance
- Error handling included in all methods
- Services follow clean architecture patterns
- UI widgets are fully customizable
- All features work offline (except AI features)

Enjoy your powerful PDF editor! 🚀
