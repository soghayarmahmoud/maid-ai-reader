# Integration Guide

This document provides guidance on integrating real services into the MAID AI Reader app.

## AI Service Integration

### Option 1: OpenAI Integration

1. **Install the OpenAI package:**
   ```yaml
   dependencies:
     dart_openai: ^5.0.0
   ```

2. **Create OpenAI Service Implementation:**
   ```dart
   import 'package:dart_openai/dart_openai.dart';
   import '../domain/ai_service.dart';

   class OpenAiService implements AiService {
     OpenAiService(String apiKey) {
       OpenAI.apiKey = apiKey;
     }

     @override
     Future<String> query(String prompt, {String? context}) async {
       final systemMessage = OpenAIChatCompletionChoiceMessageModel(
         content: [
           OpenAIChatCompletionChoiceMessageContentItemModel.text(
             'You are a helpful assistant that answers questions about documents.',
           ),
         ],
         role: OpenAIChatMessageRole.system,
       );

       final userContent = context != null
           ? 'Context: $context\n\nQuestion: $prompt'
           : prompt;

       final userMessage = OpenAIChatCompletionChoiceMessageModel(
         content: [
           OpenAIChatCompletionChoiceMessageContentItemModel.text(userContent),
         ],
         role: OpenAIChatMessageRole.user,
       );

       final chatCompletion = await OpenAI.instance.chat.create(
         model: 'gpt-3.5-turbo',
         messages: [systemMessage, userMessage],
       );

       return chatCompletion.choices.first.message.content?.first.text ?? '';
     }

     @override
     Future<String> summarize(String text) async {
       return query('Summarize the following text concisely: $text');
     }

     @override
     Future<String> translate(String text, String targetLanguage) async {
       return query('Translate the following text to $targetLanguage: $text');
     }
   }
   ```

### Option 2: Google Gemini Integration

1. **Install the Google Generative AI package:**
   ```yaml
   dependencies:
     google_generative_ai: ^0.2.0
   ```

2. **Create Gemini Service Implementation:**
   ```dart
   import 'package:google_generative_ai/google_generative_ai.dart';
   import '../domain/ai_service.dart';

   class GeminiAiService implements AiService {
     final GenerativeModel _model;

     GeminiAiService(String apiKey)
         : _model = GenerativeModel(
             model: 'gemini-pro',
             apiKey: apiKey,
           );

     @override
     Future<String> query(String prompt, {String? context}) async {
       final content = context != null
           ? 'Context: $context\n\nQuestion: $prompt'
           : prompt;

       final response = await _model.generateContent([Content.text(content)]);
       return response.text ?? '';
     }

     @override
     Future<String> summarize(String text) async {
       final prompt = 'Summarize the following text concisely: $text';
       final response = await _model.generateContent([Content.text(prompt)]);
       return response.text ?? '';
     }

     @override
     Future<String> translate(String text, String targetLanguage) async {
       final prompt = 'Translate the following text to $targetLanguage: $text';
       final response = await _model.generateContent([Content.text(prompt)]);
       return response.text ?? '';
     }
   }
   ```

## Persistent Storage for Notes

### Using Hive

1. **Create Note Model with Hive:**
   ```dart
   import 'package:hive/hive.dart';

   part 'note_model.g.dart';

   @HiveType(typeId: 0)
   class NoteModel extends HiveObject {
     @HiveField(0)
     final String id;

     @HiveField(1)
     final String title;

     @HiveField(2)
     final String content;

     @HiveField(3)
     final String pdfPath;

     @HiveField(4)
     final int pageNumber;

     @HiveField(5)
     final DateTime createdAt;

     NoteModel({
       required this.id,
       required this.title,
       required this.content,
       required this.pdfPath,
       required this.pageNumber,
       required this.createdAt,
     });
   }
   ```

2. **Generate Hive Adapters:**
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Initialize Hive in main.dart:**
   ```dart
   await Hive.initFlutter();
   Hive.registerAdapter(NoteModelAdapter());
   await Hive.openBox<NoteModel>('notes');
   ```

4. **Create Repository:**
   ```dart
   class NotesRepository {
     final Box<NoteModel> _box;

     NotesRepository(this._box);

     Future<void> addNote(NoteModel note) async {
       await _box.put(note.id, note);
     }

     List<NoteModel> getAllNotes() {
       return _box.values.toList();
     }

     List<NoteModel> getNotesByPdf(String pdfPath) {
       return _box.values.where((note) => note.pdfPath == pdfPath).toList();
     }

     Future<void> deleteNote(String id) async {
       await _box.delete(id);
     }
   }
   ```

## Environment Configuration

Create a `.env` file for API keys:

```env
OPENAI_API_KEY=your_openai_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
```

Add to `.gitignore`:
```
.env
```

Use the `flutter_dotenv` package to load environment variables.

## Security Best Practices

1. **Never commit API keys** to version control
2. **Use environment variables** for sensitive data
3. **Implement rate limiting** for AI API calls
4. **Add error handling** for network failures
5. **Cache responses** when appropriate to reduce API costs

## Testing with Mock Services

The app currently uses `MockAiService` which simulates AI responses. This is useful for:
- Development without API keys
- Testing UI without API costs
- Demonstrating the app flow

Replace `MockAiService` with your chosen AI service implementation when ready.
