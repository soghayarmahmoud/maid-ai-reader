// ignore_for_file: avoid_print

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob Service for managing ads
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();

  factory AdMobService() {
    return _instance;
  }

  AdMobService._internal();

  // Ad Unit IDs
  static const String appId = 'ca-app-pub-3053984425671049~2679361858';
  static const String bannerAdUnitId = 'ca-app-pub-3053984425671049/4605950950';
  static const String interstitialAdUnitId =
      'ca-app-pub-3053984425671049/7232114293';

  // Test Ad Unit IDs (use these during development)
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  /// Initialize Google Mobile Ads SDK
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      print('✗ Error initializing Google Mobile Ads: $e');
    }
  }

  /// Create a Banner Ad Request
  AdRequest createBannerAdRequest() {
    return const AdRequest();
  }

  /// Create an Interstitial Ad Request
  AdRequest createInterstitialAdRequest() {
    return const AdRequest();
  }

  /// Get Banner Ad Unit ID (use production or test)
  String getBannerAdUnitId({bool isTest = false}) {
    return isTest ? testBannerAdUnitId : bannerAdUnitId;
  }

  /// Get Interstitial Ad Unit ID (use production or test)
  String getInterstitialAdUnitId({bool isTest = false}) {
    return isTest ? testInterstitialAdUnitId : interstitialAdUnitId;
  }
}
