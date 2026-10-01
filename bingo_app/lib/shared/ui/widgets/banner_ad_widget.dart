import 'package:bingo_app/shared/services/ad_service.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Banner AdMob que se auto-oculta para premium, iOS e quando `ads_enabled`
/// está desligado. Ocupa zero altura quando não há anúncio para mostrar.
class BannerAdWidget extends StatefulWidget {
  final AdSize size;

  const BannerAdWidget({super.key, this.size = AdSize.banner});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _unavailable = false;

  @override
  void initState() {
    super.initState();
    SubscriptionService.isPremium.addListener(_onPremiumChanged);
    _loadAd();
  }

  void _onPremiumChanged() {
    if (!mounted) return;
    if (SubscriptionService.isPremium.value) {
      _disposeAd();
      setState(() => _unavailable = true);
    } else if (_bannerAd == null) {
      setState(() => _unavailable = false);
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final unitId = AdService.bannerAdUnitId;
    if (unitId == null || !AdService.canShowAds) {
      _markUnavailable();
      return;
    }

    final ready = await AdService.ensureInitialized();
    if (!mounted) return;
    if (!ready) {
      _markUnavailable();
      return;
    }

    final ad = BannerAd(
      adUnitId: unitId,
      request: const AdRequest(),
      size: widget.size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
            _unavailable = true;
          });
        },
      ),
    );
    _bannerAd = ad;
    await ad.load();
  }

  void _markUnavailable() {
    if (!mounted) return;
    setState(() => _unavailable = true);
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  @override
  void dispose() {
    SubscriptionService.isPremium.removeListener(_onPremiumChanged);
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (_isLoaded && ad != null) {
      return RepaintBoundary(
        child: Container(
          alignment: Alignment.center,
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      );
    }
    if (_unavailable || !AdService.canShowAds) {
      return const SizedBox.shrink();
    }
    // Reserva o espaço enquanto carrega para evitar salto de layout.
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
        const Text('Simulate Lobby Context'),
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
