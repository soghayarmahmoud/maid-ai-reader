# Quick Start Guide

Get MAID AI Reader up and running in minutes!

## Prerequisites

- Flutter SDK 3.0+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Android Studio or VS Code with Flutter extensions
- Git
- An AI API key (OpenAI or Google Gemini)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/soghayarmahmoud/maid-ai-reader.git
cd maid-ai-reader
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure AI Service (Optional for Basic Testing)

The app works with mock AI service by default. To enable real AI:

**Option A: OpenAI**
```bash
# Copy environment template
cp .env.example .env

# Edit .env and add your OpenAI API key
# OPENAI_API_KEY=your_key_here
```

**Option B: Google Gemini**
```bash
# Copy environment template
cp .env.example .env

# Edit .env and add your Gemini API key
# GEMINI_API_KEY=your_key_here
```

For detailed integration, see [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)

### 4. Run the App

**On Android:**
```bash
flutter run
```

**On iOS (Mac only):**
```bash
flutter run -d ios
```

**On specific device:**
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

## First Run

1. **Home Screen:** You'll see the library page with "Open PDF" button
2. **Open a PDF:** Tap the button to select a PDF from your device
3. **Explore Features:**
   - Navigate pages using bottom toolbar
   - Search text using search icon
   - Chat with AI about the document
   - Create notes linked to pages
   - Translate selected text

## Features Quick Access

### PDF Navigation
- **Next Page:** Bottom toolbar → Right arrow
- **Previous Page:** Bottom toolbar → Left arrow
- **Jump to Page:** Tap page indicator
- **Search:** Search icon in app bar

### AI Features (Requires API Key)
- **Ask Questions:** Chat bubble icon → Type question
- **Summarize:** In notes page → Star icon
- **Translate:** Select text → Translate icon

### Notes
- **Create Note:** Note icon → Plus button
- **View Notes:** Note icon in PDF reader
- **Delete Note:** Swipe or tap delete icon

### Theme
- **Toggle Theme:** Sun/moon icon in app bar

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/core_utils_test.dart
```

### Check Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Check for outdated packages
flutter pub outdated
```

## Troubleshooting

### "Package not found" errors
```bash
flutter clean
flutter pub get
```

### Build errors on iOS
```bash
cd ios
pod install
cd ..
flutter run
```

### Permission errors (Android)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### Syncfusion License (Optional)
Syncfusion requires a license for commercial use. For development:
1. Get a free community license from [Syncfusion](https://www.syncfusion.com/account/claim-license-key)
2. Add to `lib/main.dart`:
```dart
SyncfusionLicense.registerLicense('YOUR_LICENSE_KEY');
```

## Next Steps

1. **Integrate Real AI:** Follow [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
2. **Add Persistence:** Implement Hive storage for notes
3. **Customize:** Modify themes, colors, strings in `lib/core/constants/`
4. **Contribute:** See [CONTRIBUTING.md](CONTRIBUTING.md)

## Development Mode

The app currently uses mock AI services for development. You can:
- Test UI without API costs
- Demonstrate features
- Develop new features

To switch to real AI, update the service in `lib/di/service_locator.dart`

## Resources

- **Documentation:** See `docs/` folder
- **API Reference:** See [AI_SERVICE_GUIDE.md](AI_SERVICE_GUIDE.md)
- **Issues:** See [TODO.md](TODO.md)
- **Contributing:** See [CONTRIBUTING.md](CONTRIBUTING.md)

## Getting Help

1. Check existing documentation
2. Look at code comments
3. Review integration guides
4. Open an issue on GitHub

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE)

---

**Happy Coding! 🎉**
