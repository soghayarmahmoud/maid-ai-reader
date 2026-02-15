# Changelog

All notable changes to MAID AI Reader will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-02-02

### Added

#### EPIC: Project Setup
- Clean Architecture base structure with feature-based modules
- Core folder with constants, errors, utils, and reusable widgets
- Features folder with modular feature organization
- Assets folder structure for images and icons
- Dependency injection setup with GetIt
- Main app entry point with theme management

#### EPIC: Global Theme & Constants
- Light and dark theme support with Material 3
- App color palette with primary, secondary, and semantic colors
- App-wide constants for strings and text
- Theme switching functionality
- Custom theme configuration for all UI components

#### EPIC: PDF Reader
- PDF viewer integration using Syncfusion PDF viewer
- File picker for opening PDFs from device storage
- Smooth page navigation with next/previous controls
- Page indicator showing current page and total pages
- Jump to specific page functionality
- Text search within PDF documents
- Search result highlighting
- Text selection support

#### EPIC: AI Search
- AI service abstraction interface
- Mock AI service implementation for development
- AI chat interface for asking questions about PDFs
- Context-aware AI responses based on selected text
- Chat history display with timestamps
- Loading states for AI responses

#### EPIC: Smart Notes
- Note creation interface
- Note entity with title, content, PDF path, and page number
- Notes display filtered by PDF document
- Link notes to specific PDF pages
- Delete note functionality
- AI summarization UI (ready for integration)

#### EPIC: Translator
- Translation sheet modal
- Language selector with 10+ languages
- Selected text translation
- Translation display with formatted results
- Mock translation service (ready for integration)

#### EPIC: Testing
- Unit tests for text utility functions
- Unit tests for note entity
- Test infrastructure setup with flutter_test
- Test coverage for core utilities

### Documentation
- Comprehensive README with setup instructions
- Integration guide for AI services (OpenAI, Gemini)
- Contributing guidelines
- AI service architecture documentation
- Environment configuration examples

### Dependencies
- flutter_bloc for state management
- syncfusion_flutter_pdfviewer for PDF viewing
- file_picker for file selection
- get_it for dependency injection
- hive for local storage
- dio for network requests
- And more (see pubspec.yaml)

## [Unreleased]

### To Be Added
- Real AI service integration (OpenAI or Google Gemini)
- Persistent storage for notes using Hive
- Note editing functionality
- Note search and filtering
- PDF annotations and highlights
- Bookmarks support
- Export notes functionality
- Multi-language support for UI
- Settings page for app configuration
- Recent files history persistence
- PDF file metadata display
- More comprehensive test coverage

### Known Limitations
- AI features use mock implementations
- Notes are stored in memory only (not persisted)
- No user authentication
- Limited to PDF files only (no DOCX, TXT support yet)
- No offline AI support
- Translation requires internet connection

## Notes for Future Versions

### Version 1.1.0 (Planned)
- Real AI service integration
- Persistent note storage
- Enhanced PDF navigation

### Version 1.2.0 (Planned)
- PDF annotations
- Note categories/tags
- Export functionality

### Version 2.0.0 (Planned)
- Multi-format support (DOCX, TXT)
- Local AI model support
- Advanced search features
