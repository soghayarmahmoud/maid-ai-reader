# TODO - Future Development Tasks

This document outlines remaining tasks and future enhancements for MAID AI Reader.

## High Priority

### 1. AI Service Integration
**Status:** Ready for implementation  
**Guide:** See `INTEGRATION_GUIDE.md` and `AI_SERVICE_GUIDE.md`

**Tasks:**
- [ ] Choose AI provider (OpenAI or Google Gemini)
- [ ] Obtain API key
- [ ] Implement real AI service class
- [ ] Replace `MockAiService` with real implementation
- [ ] Update dependency injection
- [ ] Test AI responses
- [ ] Add error handling for API failures
- [ ] Implement rate limiting

**Files to update:**
- `lib/features/ai_search/data/mock_ai_service.dart` - Replace with real service
- `lib/di/service_locator.dart` - Register real service
- Create `.env` file with API key

---

### 2. Persistent Note Storage
**Status:** Ready for implementation  
**Guide:** See `INTEGRATION_GUIDE.md`

**Tasks:**
- [ ] Create Hive Note model with TypeAdapter
- [ ] Run build_runner to generate adapters
- [ ] Initialize Hive in main.dart
- [ ] Create NotesRepository with Hive
- [ ] Update NotesPage to use repository
- [ ] Add note editing functionality
- [ ] Implement note search/filtering

**Files to create/update:**
- `lib/features/smart_notes/data/models/note_model.dart` - Hive model
- `lib/features/smart_notes/data/repositories/notes_repository.dart` - Repository implementation
- `lib/features/smart_notes/presentation/notes_page.dart` - Update to use repository
- `lib/di/service_locator.dart` - Register repository

---

### 3. Testing in Flutter Environment
**Status:** Needs Flutter SDK

**Tasks:**
- [ ] Install Flutter SDK (3.0+)
- [ ] Run `flutter pub get`
- [ ] Run `flutter analyze`
- [ ] Fix any linting issues
- [ ] Run `flutter test`
- [ ] Fix any test failures
- [ ] Test on Android emulator
- [ ] Test on iOS simulator (if on Mac)
- [ ] Test on physical devices

---

## Medium Priority

### 4. Enhanced PDF Features

**Tasks:**
- [ ] Add PDF annotations (highlight, underline, strikethrough)
- [ ] Implement bookmarks for important pages
- [ ] Add highlight colors selection
- [ ] Implement annotation persistence
- [ ] Add page thumbnails view
- [ ] Implement zoom controls in UI
- [ ] Add night mode specifically for PDF reading

**Files to update:**
- `lib/features/pdf_reader/presentation/pdf_reader_page.dart`
- Create `lib/features/pdf_reader/presentation/widgets/annotation_toolbar.dart`

---

### 5. Settings Page

**Tasks:**
- [ ] Create settings page UI
- [ ] Add AI provider selection
- [ ] Add API key configuration
- [ ] Theme preference persistence
- [ ] Default language for translation
- [ ] PDF viewer preferences (zoom level, page mode)
- [ ] Clear cache option
- [ ] About page with version info

**Files to create:**
- `lib/features/settings/presentation/settings_page.dart`
- `lib/features/settings/data/settings_repository.dart`

---

### 6. Recent Files & Library Management

**Tasks:**
- [ ] Persist recent files list
- [ ] Add file metadata (last opened, page number)
- [ ] Implement file favorites/bookmarks
- [ ] Add file categories/collections
- [ ] Implement search in library
- [ ] Add sorting options (name, date, size)
- [ ] Display file thumbnails

**Files to update:**
- `lib/features/library/presentation/library_page.dart`
- Create `lib/features/library/data/library_repository.dart`

---

## Low Priority / Future Enhancements

### 7. Advanced AI Features

**Tasks:**
- [ ] Implement streaming responses from AI
- [ ] Add voice input for questions
- [ ] Add voice output for AI responses
- [ ] Context window management for long PDFs
- [ ] Multi-modal AI (analyze images in PDFs)
- [ ] Custom AI prompts/templates
- [ ] AI-powered document comparison

---

### 8. Export & Share Features

**Tasks:**
- [ ] Export notes as PDF
- [ ] Export notes as Markdown
- [ ] Share notes via email/messaging
- [ ] Export highlighted text
- [ ] Cloud backup for notes
- [ ] Sync notes across devices

---

### 9. Multi-Format Support

**Tasks:**
- [ ] Add DOCX file support
- [ ] Add TXT file support
- [ ] Add EPUB support (ebooks)
- [ ] Add image OCR (extract text from images)
- [ ] Add markdown file support

**Dependencies needed:**
- Word document: `docx_to_text` or similar
- EPUB: `epub_view` or similar
- OCR: `google_ml_kit` or `firebase_ml_vision`

---

### 10. UI/UX Improvements

**Tasks:**
- [ ] Add animations for page transitions
- [ ] Implement pull-to-refresh
- [ ] Add haptic feedback
- [ ] Implement custom splash screen
- [ ] Add onboarding flow for new users
- [ ] Improve accessibility (screen reader support)
- [ ] Add keyboard shortcuts (for tablets)

---

### 11. Performance Optimizations

**Tasks:**
- [ ] Implement lazy loading for large PDFs
- [ ] Add image caching
- [ ] Optimize memory usage
- [ ] Add performance monitoring
- [ ] Implement background PDF loading
- [ ] Add app size optimization

---

### 12. Security & Privacy

**Tasks:**
- [ ] Add password protection for app
- [ ] Implement file encryption
- [ ] Add biometric authentication
- [ ] Secure storage for API keys
- [ ] Privacy policy and terms of service
- [ ] GDPR compliance features

---

### 13. Analytics & Monitoring

**Tasks:**
- [ ] Add Firebase Analytics (optional)
- [ ] Implement crash reporting
- [ ] Add performance monitoring
- [ ] Usage statistics (offline, no personal data)
- [ ] Feature usage tracking

---

### 14. Internationalization (i18n)

**Tasks:**
- [ ] Set up flutter_localizations
- [ ] Create translation files for multiple languages
- [ ] Implement language switching in settings
- [ ] Support RTL languages (Arabic, Hebrew)
- [ ] Localize date/time formats

**Languages to support:**
- English (default) ✓
- Spanish
- French
- German
- Arabic
- Chinese
- Japanese

---

## Testing Expansion

### Unit Tests
- [ ] Test PDF repository
- [ ] Test AI service implementations
- [ ] Test notes repository
- [ ] Test translation service
- [ ] Test settings repository

### Widget Tests
- [ ] Test PDF reader page
- [ ] Test library page
- [ ] Test notes page
- [ ] Test AI chat page
- [ ] Test translation sheet
- [ ] Test all custom widgets

### Integration Tests
- [ ] Test complete PDF viewing flow
- [ ] Test note creation and retrieval
- [ ] Test AI chat flow
- [ ] Test translation flow
- [ ] Test theme switching

---

## Code Quality

**Tasks:**
- [ ] Increase test coverage to >80%
- [ ] Add documentation comments to all public APIs
- [ ] Run static code analysis
- [ ] Fix all linting warnings
- [ ] Implement CI/CD pipeline
- [ ] Set up automated testing

---

## Placeholder Files to Implement

The following empty files exist as scaffolding and should be implemented:

### AI Search Feature
- `lib/features/ai_search/data/sources/ai_remote_source.dart`
- `lib/features/ai_search/data/repositories/ai_repository_impl.dart`
- `lib/features/ai_search/domain/ai_search_usecase.dart`

### Translator Feature
- `lib/features/translator/data/translation_service.dart`
- `lib/features/translator/domain/translate_text.dart`

### Smart Notes Feature
- `lib/features/smart_notes/data/notes_repository_impl.dart`
- `lib/features/smart_notes/domain/usecases/summarize_note.dart`
- `lib/features/smart_notes/domain/usecases/add_note.dart`
- `lib/features/smart_notes/domain/usecases/get_notes_by_pdf.dart`
- `lib/features/smart_notes/domain/repositories/notes_repository.dart`

### PDF Reader Feature
- `lib/features/pdf_reader/data/models/pdf_document_model.dart`
- `lib/features/pdf_reader/data/repositories/pdf_repository_impl.dart`
- `lib/features/pdf_reader/domain/usecases/open_pdf.dart`
- `lib/features/pdf_reader/domain/usecases/search_pdf.dart`

### Settings Feature
- `lib/features/settings/settings_page.dart`

---

## Notes

- This is a living document - add tasks as needed
- Mark tasks complete with [x] when done
- Update CHANGELOG.md when completing major features
- Consider creating GitHub issues for tracking
