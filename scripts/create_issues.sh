#!/bin/bash

# Script to create GitHub issues for MAID AI Reader
# Prerequisites: GitHub CLI (gh) must be installed and authenticated
# Usage: ./scripts/create_issues.sh

set -e

echo "🚀 Creating GitHub Issues for MAID AI Reader"
echo "============================================"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "📥 Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "🔐 Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is ready!"
echo ""

# Issue #1 - Setup Clean Architecture Base
echo "📝 Creating Issue #1: Setup Clean Architecture Base..."
gh issue create \
  --title "Setup Clean Architecture Base" \
  --label "feature,architecture,good first issue" \
  --body "## Description
Create the base project structure following Clean Architecture with feature-based modules. This will be the foundation for all future development.

## Tasks
- [x] Create core, features, assets folders
- [x] Apply feature-based Clean Architecture
- [x] Setup base app navigation
- [x] Configure dependency injection with GetIt
- [x] Create main.dart entry point

## Acceptance Criteria
- [x] App runs without errors
- [x] Folder structure matches architecture plan
- [x] Empty feature screens render correctly
- [x] Clean separation of domain/data/presentation layers

## Status
✅ Complete

See \`lib/\` directory for implementation."

echo "✅ Issue #1 created!"
echo ""

# Issue #2 - Global Theme & Constants
echo "📝 Creating Issue #2: Global Theme & Constants..."
gh issue create \
  --title "Global Theme & Constants" \
  --label "feature,ui,enhancement" \
  --body "## Description
Implement global theming, colors, and text styles to ensure consistent UI across the app.

## Tasks
- [x] Define light/dark themes
- [x] Create app colors and text styles
- [x] Apply theme to MaterialApp
- [x] Implement theme switching functionality
- [x] Create centralized constants for strings

## Acceptance Criteria
- [x] Theme applied globally
- [x] Easy theme switching supported
- [x] No hardcoded colors in UI
- [x] Material 3 design system implemented

## Status
✅ Complete

See \`lib/core/constants/\` for implementation."

echo "✅ Issue #2 created!"
echo ""

# Issue #3 - Implement PDF Viewer
echo "📝 Creating Issue #3: Implement PDF Viewer..."
gh issue create \
  --title "Implement PDF Viewer" \
  --label "feature,pdf" \
  --body "## Description
Add a PDF viewer that allows users to open and read PDF files smoothly.

## Tasks
- [x] Integrate PDF viewer package (Syncfusion)
- [x] Open PDF from local storage using file picker
- [x] Display pages with scrolling
- [x] Implement zoom functionality
- [x] Handle large files gracefully

## Acceptance Criteria
- [x] PDF loads successfully
- [x] Smooth scrolling and zoom
- [x] No app crashes on large files
- [x] File picker integration works

## Status
✅ Complete

See \`lib/features/pdf_reader/\` for implementation."

echo "✅ Issue #3 created!"
echo ""

# Issue #4 - PDF Page Navigation
echo "📝 Creating Issue #4: PDF Page Navigation..."
gh issue create \
  --title "PDF Page Navigation" \
  --label "feature,pdf,ui" \
  --body "## Description
Allow users to navigate between pages easily using toolbar controls.

## Tasks
- [x] Page indicator showing current/total pages
- [x] Jump to page dialog
- [x] Next / previous page buttons
- [x] Track page changes
- [x] Disable buttons at boundaries

## Acceptance Criteria
- [x] Page navigation works correctly
- [x] Current page displayed accurately
- [x] Jump to page dialog functional
- [x] Navigation buttons respond appropriately

## Status
✅ Complete

See \`lib/features/pdf_reader/presentation/pdf_reader_page.dart\` for implementation."

echo "✅ Issue #4 created!"
echo ""

# Issue #5 - Search Inside PDF
echo "📝 Creating Issue #5: Search Inside PDF..."
gh issue create \
  --title "Search Inside PDF" \
  --label "feature,pdf" \
  --body "## Description
Implement text search functionality inside the opened PDF document.

## Tasks
- [x] Search text inside PDF
- [x] Highlight search results
- [x] Navigate between results
- [x] Add search UI with toggle
- [x] Clear search functionality

## Acceptance Criteria
- [x] Search returns accurate matches
- [x] Highlights visible
- [x] Handles large documents
- [x] Search bar collapses when not needed

## Status
✅ Complete

See \`lib/features/pdf_reader/presentation/pdf_reader_page.dart\` for implementation."

echo "✅ Issue #5 created!"
echo ""

# Issue #6 - AI Service Integration
echo "📝 Creating Issue #6: AI Service Integration..."
gh issue create \
  --title "AI Service Integration" \
  --label "feature,ai" \
  --body "## Description
Integrate AI API to allow intelligent interaction with PDF content.

## Tasks
- [x] Create AI service abstraction interface
- [x] Send text to AI API
- [x] Handle API responses & errors
- [x] Implement mock service for development
- [ ] Integrate real AI provider (OpenAI/Gemini)

## Acceptance Criteria
- [x] AI returns valid responses
- [x] Errors handled gracefully
- [x] Easy to switch AI provider
- [x] Service abstraction follows Clean Architecture

## Status
🔄 Ready for Integration

See \`INTEGRATION_GUIDE.md\` for next steps.
See \`lib/features/ai_search/\` for implementation."

echo "✅ Issue #6 created!"
echo ""

# Issue #7 - Ask Questions About PDF
echo "📝 Creating Issue #7: Ask Questions About PDF..."
gh issue create \
  --title "Ask Questions About PDF" \
  --label "feature,ai,pdf" \
  --body "## Description
Allow users to ask questions related to selected PDF text or pages using AI.

## Tasks
- [x] Select text from PDF
- [x] Send context to AI
- [x] Display response in UI
- [x] Create chat interface
- [x] Add chat history
- [x] Handle loading states

## Acceptance Criteria
- [x] AI answers are relevant (with mock service)
- [x] Context-aware responses supported
- [x] Smooth UI experience
- [x] Chat bubbles with timestamps

## Status
✅ Complete (UI), 🔄 Needs real AI integration

See \`lib/features/ai_search/presentation/ai_chat_page.dart\` for implementation."

echo "✅ Issue #7 created!"
echo ""

# Issue #8 - Create Smart Notes
echo "📝 Creating Issue #8: Create Smart Notes..."
gh issue create \
  --title "Create Smart Notes" \
  --label "feature,notes" \
  --body "## Description
Enable users to create notes linked to specific PDF pages.

## Tasks
- [x] Create note entity
- [x] Save notes locally (in-memory)
- [x] Link note to PDF + page number
- [x] Create note UI with dialog
- [x] Display notes filtered by PDF
- [x] Delete note functionality
- [ ] Implement Hive persistence

## Acceptance Criteria
- [x] Notes persist during app session
- [x] Notes correctly linked to PDFs
- [x] Note creation UI functional
- [ ] Notes persist after app restart (needs Hive)

## Status
✅ Complete (UI), 🔄 Needs persistence

See \`lib/features/smart_notes/\` for implementation.
See \`INTEGRATION_GUIDE.md\` for Hive setup."

echo "✅ Issue #8 created!"
echo ""

# Issue #9 - AI Summarized Notes
echo "📝 Creating Issue #9: AI Summarized Notes..."
gh issue create \
  --title "AI Summarized Notes" \
  --label "feature,ai,notes" \
  --body "## Description
Use AI to automatically summarize selected PDF text into concise notes.

## Tasks
- [x] Send selected text to AI
- [x] Generate summary
- [x] Save as note
- [x] Add summarize button in UI
- [ ] Integrate with real AI service

## Acceptance Criteria
- [x] UI for summarization ready
- [ ] Notes are concise and accurate (needs AI)
- [x] AI summary clearly readable

## Status
✅ Complete (UI), 🔄 Needs real AI integration

See \`lib/features/smart_notes/presentation/notes_page.dart\` for implementation."

echo "✅ Issue #9 created!"
echo ""

# Issue #10 - Translate Selected Text
echo "📝 Creating Issue #10: Translate Selected Text..."
gh issue create \
  --title "Translate Selected Text" \
  --label "feature,ai,translation" \
  --body "## Description
Allow users to translate selected PDF text into different languages using AI.

## Tasks
- [x] Language selector with 10+ languages
- [x] Send text for translation
- [x] Display translated result
- [x] Create translation modal sheet
- [x] Implement mock translation service
- [ ] Integrate with real translation service

## Acceptance Criteria
- [x] Translation UI functional
- [x] Multiple languages supported
- [x] Translation result displays properly
- [ ] Translation preserves meaning (needs real service)

## Status
✅ Complete (UI), 🔄 Needs real translation service

See \`lib/features/translator/presentation/translate_sheet.dart\` for implementation."

echo "✅ Issue #10 created!"
echo ""

# Issue #11 - Unit Tests for Core Features
echo "📝 Creating Issue #11: Unit Tests for Core Features..."
gh issue create \
  --title "Unit Tests for Core Features" \
  --label "testing,quality" \
  --body "## Description
Add unit tests to ensure core functionality works correctly.

## Tasks
- [x] Test PDF use cases (placeholder)
- [x] Test AI services (mocked)
- [x] Test notes logic
- [x] Test core utilities (text helpers)
- [x] Setup test infrastructure
- [ ] Increase test coverage to >80%

## Acceptance Criteria
- [x] Tests pass successfully
- [x] Coverage for main logic started
- [x] Test infrastructure in place
- [ ] Comprehensive test coverage

## Status
✅ Complete (Basic), 🔄 Needs more coverage

See \`test/\` directory for implementation."

echo "✅ Issue #11 created!"
echo ""

echo "============================================"
echo "🎉 All issues created successfully!"
echo ""
echo "📝 View issues: gh issue list"
echo "🌐 Or visit: https://github.com/soghayarmahmoud/maid-ai-reader/issues"
echo ""
