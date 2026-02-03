# 🛡️ MAID - Smart AI Document Reader

![MAID Logo](assets/images/logo.png) 

**MAID** (Mobile AI Document-assistant) is a next-generation document reader built with **Flutter**. It doesn't just display text; it understands it.

## ✨ Key Features
* **📄 PDF Support:** Seamlessly read PDF files with smooth scrolling and zoom.
* **🤖 AI Chat:** Ask questions about your PDFs and get instant AI-powered answers.
* **💡 Smart Search:** Find text within your documents quickly.
* **📝 Smart Notes:** Create notes linked to specific PDF pages with AI summarization.
* **🌍 Translator:** Translate selected text into multiple languages.
* **🎨 Theme Support:** Toggle between light and dark modes.

## 🚀 Tech Stack
* **Framework:** [Flutter](https://flutter.dev) 3.0+
* **State Management:** flutter_bloc
* **Dependency Injection:** get_it
* **AI Integration:** Configurable (OpenAI API / Google Gemini API)
* **Local Storage:** Hive & SharedPreferences
* **PDF Engine:** syncfusion_flutter_pdfviewer

## 📋 Features Implementation Status

### ✅ Completed
- [x] Issue #1 - Setup Clean Architecture Base
- [x] Issue #2 - Global Theme & Constants
- [x] Issue #3 - Implement PDF Viewer
- [x] Issue #4 - PDF Page Navigation
- [x] Issue #5 - Search Inside PDF
- [x] Issue #6 - AI Service Integration (Interface)
- [x] Issue #7 - Ask Questions About PDF (UI)
- [x] Issue #8 - Create Smart Notes
- [x] Issue #9 - AI Summarized Notes (UI)
- [x] Issue #10 - Translate Selected Text (UI)
- [x] Issue #11 - Unit Tests for Core Features

### 🔄 Requires Integration
- [ ] Connect real AI service (OpenAI/Gemini API)
- [ ] Implement persistent storage for notes
- [ ] Add more comprehensive tests

> 📝 **For detailed issue descriptions and tracking**, see [GITHUB_ISSUES.md](GITHUB_ISSUES.md)  
> 🚀 **To create these as GitHub issues**, run `./scripts/create_issues.sh`

## 🛠️ Installation & Setup

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- An AI API key (OpenAI or Google Gemini)

### Steps

1. **Clone the repo:**
   ```bash
   git clone https://github.com/soghayarmahmoud/maid-ai-reader.git
   cd maid-ai-reader
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure AI Service:**
   - Open `lib/features/ai_search/data/mock_ai_service.dart`
   - Replace `MockAiService` with your actual AI service implementation
   - Add your API key to environment variables or secure storage

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📱 Usage

1. **Open a PDF:** Tap the "Open PDF" button on the home screen
2. **Navigate Pages:** Use the toolbar at the bottom to navigate between pages
3. **Search:** Tap the search icon in the app bar to search within the PDF
4. **AI Chat:** Tap the chat icon to ask questions about the document
5. **Take Notes:** Tap the note icon to create smart notes linked to the current page
6. **Translate:** Select text and tap the translate icon to translate it

## 🏗️ Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App colors, strings, theme
│   ├── errors/             # Error handling
│   ├── utils/              # Utility functions
│   └── widgets/            # Reusable widgets
├── di/                      # Dependency injection
├── features/                # Feature modules
│   ├── ai_search/          # AI chat functionality
│   ├── library/            # Home screen/library
│   ├── pdf_reader/         # PDF viewing
│   ├── smart_notes/        # Note-taking
│   └── translator/         # Translation
├── app.dart                 # Main app widget
└── main.dart                # Entry point
```

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 🔐 Security & Privacy

- All data is stored locally on the device
- AI queries are sent to configured AI service
- No data is collected or shared without user consent

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Syncfusion for the excellent PDF viewer
- Flutter team for the amazing framework
- OpenAI/Google for AI capabilities

## 📞 Contact

Mahmoud Soghayar - [@soghayarmahmoud](https://github.com/soghayarmahmoud)

Project Link: [https://github.com/soghayarmahmoud/maid-ai-reader](https://github.com/soghayarmahmoud/maid-ai-reader)

