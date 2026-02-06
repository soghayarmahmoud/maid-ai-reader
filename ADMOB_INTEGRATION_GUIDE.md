# AdMob Integration Guide

## Overview

The Maid AI Reader app now includes Google AdMob integration with two types of ads:

### 1. **Full/Interstitial Ad** (اعلان بيني)
- **Type**: Interstitial Ad (full-screen ad)
- **Ad Unit ID**: `ca-app-pub-3053984425671049/7232114293`
- **Name**: `full-ad`
- **Where it appears**: Before opening a PDF from the library
- **Frequency**: Shown when user opens a PDF

### 2. **Banner Ad**
- **Type**: Banner Ad (bottom banner)
- **Ad Unit ID**: `ca-app-pub-3053984425671049/4605950950`
- **Name**: `banner-ad`
- **Where it appears**: 
  - Bottom of Library Page
  - Bottom of PDF Reader Page
  - Bottom of Settings Page
- **Frequency**: Always visible at the bottom of these pages

## App Configuration

### Application ID
- **AdMob App ID**: `ca-app-pub-3053984425671049~2679361858`
- **Already configured in**: `android/app/src/main/AndroidManifest.xml`

## File Structure

```
lib/
├── services/
│   └── admob_service.dart           # Main AdMob service manager
├── core/
│   └── widgets/
│       ├── banner_ad_widget.dart    # Banner ad widget component
│       └── interstitial_ad_manager.dart # Interstitial ad manager
├── main.dart                        # AdMob initialization
├── features/
│   ├── library/
│   │   └── presentation/
│   │       └── library_page.dart    # With interstitial & banner ads
│   ├── pdf_reader/
│   │   └── presentation/
│   │       └── pdf_reader_page.dart # With banner ad
│   └── settings/
│       └── settings_page.dart       # With banner ad
```

## Implementation Details

### 1. AdMob Service (`lib/services/admob_service.dart`)

Manages:
- Google Mobile Ads SDK initialization
- Ad Unit ID configuration
- Test vs Production ad selection

```dart
// Initialize in main()
await AdMobService().initialize();
```

### 2. Banner Ad Widget (`lib/core/widgets/banner_ad_widget.dart`)

Features:
- Automatic ad loading
- Error handling
- Test ad support
- Lifecycle management

```dart
// Usage in any page
const BannerAdWidget(isTest: false)
```

### 3. Interstitial Ad Manager (`lib/core/widgets/interstitial_ad_manager.dart`)

Features:
- Load ads asynchronously
- Show ads when ready
- Automatic retry loading after dismissal
- Full lifecycle callbacks

```dart
// Load ad (usually in background)
final manager = InterstitialAdManager();
await manager.loadInterstitialAd(isTest: false);

// Show ad when ready
if (manager.isAdLoaded) {
  await manager.showInterstitialAd();
}
```

## Integration Points

### Library Page (LibraryPage)
**File**: `lib/features/library/presentation/library_page.dart`

Changes:
- Added import for banner ad and interstitial manager
- Updated `initState()` to preload interstitial ad after 2 seconds
- Modified `_openPdf()` to show interstitial ad before opening PDF
- Wrapped body content in Column with BannerAdWidget at bottom

```dart
// In initState():
Future.delayed(const Duration(seconds: 2), () {
  InterstitialAdManager().loadInterstitialAd(isTest: false);
});

// In _openPdf():
final manager = InterstitialAdManager();
if (manager.isAdLoaded) {
  await manager.showInterstitialAd();
}
```

### PDF Reader Page (PdfReaderPage)
**File**: `lib/features/pdf_reader/presentation/pdf_reader_page.dart`

Changes:
- Added banner ad widget at bottom of page
- Ad displays while user reads PDF
- Does not interfere with PDF navigation

### Settings Page (SettingsPage)
**File**: `lib/features/settings/settings_page.dart`

Changes:
- Added banner ad at bottom of ListView
- Ad appears after all settings options

## Testing

### Test Ad Unit IDs (for development)

Use these during development to avoid policy violations:

```dart
// Banner Ad Test ID
static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

// Interstitial Ad Test ID
static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
```

### Enable Test Mode

```dart
// In AdMobService:
const bool USE_TEST_ADS = true;

// Then use:
BannerAdWidget(isTest: USE_TEST_ADS)
InterstitialAdManager().loadInterstitialAd(isTest: USE_TEST_ADS)
```

## Important Notes

### Ad Initialization
- ✅ Google Mobile Ads SDK is initialized in `main.dart`
- ✅ AdMob App ID is set in AndroidManifest.xml
- ✅ All dependencies added to pubspec.yaml

### Ad Loading Policy
- New ad units take up to **1 hour** to start serving ads
- Always test with test ad IDs first
- Recommend **2-week testing period** before evaluation

### Best Practices
1. **Interstitial Ads**: Only show when user performs an action (opens PDF)
2. **Banner Ads**: Always visible, doesn't interrupt user experience
3. **Error Handling**: App works even if ads fail to load
4. **Preloading**: Interstitial ads are preloaded in background

## Troubleshooting

### Ads not showing?
1. Check if ad unit IDs are correct
2. Verify app is in production (not test mode)
3. Wait up to 1 hour for new ad units
4. Check internet connectivity
5. Review console logs for errors

### Blank screens?
- See [ANALYSIS_AND_FIXES.md](ANALYSIS_AND_FIXES.md) for app crash fixes
- Banner ad widget should not cause blank screen (uses SizedBox.shrink if not loaded)

### Interstitial ad not showing?
- First ad may not be ready - loads in background
- Subsequent opens will show preloaded ad
- Check `InterstitialAdManager.isAdLoaded` before showing

## Performance Impact

### Bundle Size
- google_mobile_ads adds ~3-5 MB to APK
- ProGuard minification helps reduce size
- Overall app optimization already implemented

### Memory
- Banner ads consume minimal memory (~1-2 MB)
- Interstitial ads load only when needed

## Revenue Optimization

### Current Setup
- 2 banners: Bottom of Library, PDF Reader, and Settings pages
- 1 interstitial: Before opening PDFs
- Estimated impression rate: High engagement

### Future Enhancements
- Rewarded ads for premium features
- Native ads in search results
- Mediation for better fill rates

## Support

For issues with:
- **AdMob**: Visit Google AdMob Support
- **App Crashes**: See ANALYSIS_AND_FIXES.md
- **Ad Configuration**: Check AndroidManifest.xml and pubspec.yaml

---
**Last Updated**: February 6, 2026
**Status**: ✅ Production Ready
