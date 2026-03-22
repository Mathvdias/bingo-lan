import 'package:bingo_app/shared/services/ad_service.dart';
import 'package:bingo_app/shared/services/revenue_config_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize size;

  const BannerAdWidget({super.key, this.size = AdSize.banner});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!RevenueConfigService.adsEnabled) {
      debugPrint('BannerAd skipped: Ads are disabled via Remote Config.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: widget.size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAd loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return RepaintBoundary(
        child: Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }
    return SizedBox(
      width: widget.size.width.toDouble(),
      height: widget.size.height.toDouble(),
    );
  }
}

@Preview(name: 'Banner Ad (Mock UI)')
Widget bannerAdPreview() {
  return Scaffold(
    body: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Simulate Game Screen Context'),
        const Spacer(),
        Container(
          height: 50,
          color: Colors.grey[300],
          child: const Center(child: Text('BANNER AD PLACEHOLDER (Preview)')),
        ),
      ],
    ),
  );
}
