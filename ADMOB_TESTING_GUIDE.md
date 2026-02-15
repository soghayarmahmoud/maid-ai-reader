# AdMob Testing & Development Guide

## Quick Reference

### Ad Unit IDs

#### Production
```dart
// Full/Interstitial Ad (اعلان بيني)
const String interstitialAdUnitId = 'ca-app-pub-3053984425671049/7232114293';

// Banner Ad
const String bannerAdUnitId = 'ca-app-pub-3053984425671049/4605950950';

// App ID
const String appId = 'ca-app-pub-3053984425671049~2679361858';
```

#### Test (for development)
```dart
// Test Interstitial Ad
const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

// Test Banner Ad  
const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
```

### Key Files
```
lib/services/admob_service.dart              # Main service
lib/core/widgets/banner_ad_widget.dart       # Banner display
lib/core/widgets/interstitial_ad_manager.dart # Interstitial logic
```

## Testing During Development

### Using Test Ads

1. **In AdMobService** (`lib/services/admob_service.dart`):
```dart
/// Get Banner Ad Unit ID (use production or test)
String getBannerAdUnitId({bool isTest = true}) {  // Set to true for testing
  return isTest ? testBannerAdUnitId : bannerAdUnitId;
}

/// Get Interstitial Ad Unit ID (use production or test)
String getInterstitialAdUnitId({bool isTest = true}) {  // Set to true for testing
  return isTest ? testInterstitialAdUnitId : interstitialAdUnitId;
}
```

2. **In Pages** - Toggle test mode:
```dart
// LibraryPage - preload interstitial
InterstitialAdManager().loadInterstitialAd(isTest: true);  // For testing

// Show banner
BannerAdWidget(isTest: true)  // For testing
```

3. **In PdfReaderPage and SettingsPage**:
```dart
// Always use same mode
BannerAdWidget(isTest: true)  // Consistent with other pages
```

## Swift Production Checklist

- [ ] Set all `isTest: false` in app
- [ ] Test with production ad IDs on test device
- [ ] Verify ads display correctly
- [ ] Check AndroidManifest.xml has correct App ID
- [ ] Verify no console errors
- [ ] Run app in release mode: `flutter build apk --release`
- [ ] Wait for ad units to become active (up to 1 hour)
- [ ] Monitor AdMob dashboard first week
- [ ] Check revenue and impressions

## Common Issues & Solutions

### Issue: Ads not showing
**Solution**: 
1. Verify you're using production IDs
2. Check that 1 hour has passed since adding new ad units
3. Ensure internet connectivity
4. Review console logs: `flutter logs`
5. Check AdMob dashboard for issues

### Issue: App crashes when loading ad
**Solution**:
- Banner widget shows nothing if ad fails to load (not a crash)
- Ensure error handling is in place
- Check logs for specific error messages
- Review AdMobService initialization

### Issue: Interstitial ad not showing
**Solution**:
1. First ad may not be ready (preloads after 2 seconds)
2. Subsequent opens should show the ad
3. Check `InterstitialAdManager.isAdLoaded`
4. Verify ad loads in background: see console "Preloading interstitial ad"

### Issue: Ad showing blank/wrong content
**Solution**:
1. Ads take up to 1 hour to serve
2. You may be seeing test ads initially
3. This is normal behavior
4. Wait 1 hour and refresh

## Monitoring Performance

### AdMob Dashboard
Visit: https://admob.google.com

Monitor:
- **Impressions**: Number of times ad was shown
- **Clicks**: Number of user clicks
- **Click rate**: Click / Impressions
- **eCPM**: Estimated cost per 1000 impressions  
- **Earnings**: Revenue

### Console Logs
Filter for AdMob logs:
```bash
flutter logs | grep "admob\|📢\|✓\|⚠️\|✗"
```

### Expected Logs
```
✓ Google Mobile Ads initialized successfully
✓ AdMob initialized successfully
✓ Reading progress repository initialized
✓ Banner ad loaded successfully
✓ Interstitial ad loaded successfully
📢 Preparing to show interstitial ad...
```

## Advanced: Custom Implementation

### Add new banner ad placement
1. Create new page/widget
2. Import: `import '../../core/widgets/banner_ad_widget.dart';`
3. Add to Column:
```dart
Column(
  children: [
    Expanded(child: yourContent()),
    const BannerAdWidget(isTest: false),
  ],
)
```

### Add another interstitial placement
1. Import: `import '../../core/widgets/interstitial_ad_manager.dart';`  
2. Load ad (somewhere):
```dart
InterstitialAdManager().loadInterstitialAd(isTest: false);
```
3. Show ad (when needed):
```dart
final manager = InterstitialAdManager();
if (manager.isAdLoaded) {
  await manager.showInterstitialAd();
}
```

### Add Rewarded Ads (Future Enhancement)
Create `lib/core/widgets/rewarded_ad_manager.dart`:
```dart
class RewardedAdManager {
  RewardedAd? _rewardedAd;
  
  Future<void> loadRewardedAd() async {
    // Similar to InterstitialAdManager
  }
  
  Future<void> showRewardedAd() async {
    // Load and show
  }
}
```

## Mediation Setup (Optional)

Add mediation to increase fill rate:
1. Go to AdMob App settings
2. Add mediation networks (Unity Ads, AppLovin, etc.)
3. Configure waterfall logic
4. Monitor performance

## Performance Tips

### Reduce APK Size
- App already has ProGuard minification
- Consider R8 for even better compression
- Remove unused assets

### Memory Optimization  
- Banner ads: Minimal memory footprint
- Interstitial: Disposed after shown
- Monitor with Android Profiler

### User Experience
- ✅ Don't show ads on every action
- ✅ Preload ads to avoid delays
- ✅ Dismiss ads quickly
- ✅ Don't force watch time

## Documentation Links

- [Google Mobile Ads Flutter Plugin Docs](https://pub.dev/packages/google_mobile_ads)
- [AdMob Best Practices](https://support.google.com/admob)
- [Google Play Ad Policy](https://play.google.com/about/monetization-ads/)

## Support Contacts

- **AdMob Issues**: admob-support@google.com
- **App Issues**: See ANALYSIS_AND_FIXES.md
- **General Flutter**: https://flutter.dev/support

---

### Quick Swap: Test ↔ Production

To quickly switch between test and production ads:

**Option 1: Use GlobalVariable**
```dart
// At top of main.dart
const bool USE_TEST_ADS = true;  // Change to false for production

// In pages
BannerAdWidget(isTest: USE_TEST_ADS)
```

**Option 2: Use BuildConfiguration**  
```dart
// In pubspec.yaml or build gradle
bool isTestAds = const bool.fromEnvironment('TEST_ADS', defaultValue: true);
```

**Recommended**: Keep isTest parameter in code for explicit control per location.

---
**Last Updated**: February 6, 2026
**Maintained By**: Development Team
