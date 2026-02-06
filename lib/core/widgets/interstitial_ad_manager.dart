import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/admob_service.dart';

/// Manager for Interstitial Ads
class InterstitialAdManager {
  static final InterstitialAdManager _instance =
      InterstitialAdManager._internal();

  factory InterstitialAdManager() {
    return _instance;
  }

  InterstitialAdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  bool _isTest = false;

  /// Load an Interstitial Ad
  Future<void> loadInterstitialAd({bool isTest = false}) async {
    _isTest = isTest;
    try {
      await InterstitialAd.load(
        adUnitId: AdMobService().getInterstitialAdUnitId(isTest: isTest),
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            print('✓ Interstitial ad loaded successfully');

            // Set up listeners for ad lifecycle
            _interstitialAd!.fullScreenContentCallback =
                FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                print('📢 Interstitial ad showed full screen content');
              },
              onAdDismissedFullScreenContent: (ad) {
                print('📢 Interstitial ad dismissed');
                ad.dispose();
                _isInterstitialAdLoaded = false;
                // Optionally reload ad after dismissal
                // loadInterstitialAd(isTest: isTest);
              },
              onAdFailedToShowFullScreenContent: (ad, err) {
                print('✗ Interstitial ad failed to show: ${err.message}');
                ad.dispose();
                _isInterstitialAdLoaded = false;
              },
              onAdImpression: (ad) {
                print('📊 Interstitial ad impression');
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('✗ Interstitial ad failed to load: ${error.message}');
            _isInterstitialAdLoaded = false;
          },
        ),
      );
    } catch (e) {
      print('✗ Error loading interstitial ad: $e');
      _isInterstitialAdLoaded = false;
    }
  }

  /// Show the Interstitial Ad if it's loaded
  Future<void> showInterstitialAd() async {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      try {
        await _interstitialAd!.show();
        print('✓ Interstitial ad displayed');
      } catch (e) {
        print('✗ Error showing interstitial ad: $e');
      }
    } else {
      print('⚠️ Interstitial ad not loaded yet');
    }
  }

  /// Check if interstitial ad is ready
  bool get isAdLoaded => _isInterstitialAdLoaded;

  /// Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
  }
}
