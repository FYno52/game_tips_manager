import 'package:flutter/material.dart';
import 'package:game_tips_manager/ad_helper.dart';
import 'package:game_tips_manager/screens/manual.dart';
import 'package:game_tips_manager/screens/tips_start_title_screen.dart';
import 'package:game_tips_manager/widgets/back_ground.dart';
import 'package:game_tips_manager/widgets/custom_drawer.dart';
import 'package:game_tips_manager/widgets/select_button.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;

  @override
  void initState() {
    super.initState();
    _loadTopBannerAd();
    _loadBottomBannerAd();
  }

  void _loadTopBannerAd() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _topBannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();
  }

  void _loadBottomBannerAd() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bottomBannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 125, 255),
        title: const Text('Select Mode'),
      ),
      body: Column(
        children: [
          SizedBox(
            width: AdSize.banner.width.toDouble(),
            height: AdSize.banner.height.toDouble(),
            child: _topBannerAd != null
                ? AdWidget(ad: _topBannerAd!)
                : Container(color: Colors.transparent),
          ),
          const Expanded(
            child: BackGround(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectButton(
                      text: "CreateTips",
                      destinationPage: TipsStartTitleScreen(),
                    ),
                    SizedBox(height: 16), // Spacing between buttons
                    SelectButton(
                      text: "Manual",
                      destinationPage: ManualPage(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: AdSize.banner.width.toDouble(),
            height: AdSize.banner.height.toDouble(),
            child: _bottomBannerAd != null
                ? AdWidget(ad: _bottomBannerAd!)
                : Container(color: Colors.transparent),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
    );
  }
}
