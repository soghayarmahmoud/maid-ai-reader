import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/admob_service.dart';

/// Widget for displaying Google Mobile Ads Banner Ad
class BannerAdWidget extends StatefulWidget {
  final bool isTest;
  final double height;

  const BannerAdWidget({
    super.key,
    this.isTest = false,
    this.height = 60,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobService().getBannerAdUnitId(isTest: widget.isTest),
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
            print('✓ Banner ad loaded successfully');
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('✗ Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
        onAdOpened: (Ad ad) {
          print('📢 Banner ad opened');
        },
        onAdClosed: (Ad ad) {
          print('📢 Banner ad closed');
        },
        onAdImpression: (Ad ad) {
          print('📊 Banner ad impression');
        },
        onAdClicked: (Ad ad) {
          print('👆 Banner ad clicked');
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBannerAdLoaded) {
      return const SizedBox.shrink(); // Hide until ad is loaded
    }

    return Container(
      height: _bannerAd.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd),
    );
  }
}
