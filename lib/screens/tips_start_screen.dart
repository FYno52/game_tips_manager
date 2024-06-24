import 'package:flutter/material.dart';
import 'package:game_tips_manager/ad_helper.dart';
import 'package:game_tips_manager/widgets/back_ground.dart';
import 'package:game_tips_manager/widgets/custom_drawer.dart';
import 'package:game_tips_manager/widgets/map_select_button.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TipsStartScreen extends StatefulWidget {
  const TipsStartScreen({super.key});

  @override
  _TipsStartScreenState createState() => _TipsStartScreenState();
}

class _TipsStartScreenState extends State<TipsStartScreen> {
  bool _showIntro = false;
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _loadTopBannerAd();
    _loadBottomBannerAd();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownIntro = prefs.getBool('hasShownIntro') ?? false;
    if (!hasShownIntro) {
      setState(() {
        _showIntro = true;
      });
      await prefs.setBool('hasShownIntro', true);
    }
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

  void _closeIntroDialog() {
    setState(() {
      _showIntro = false;
    });
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
        title: const Text('Select Map - Save Tips'),
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
          Expanded(
            child: Stack(
              children: [
                const BackGround(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "ascent", mapName: "Ascent"),
                            ),
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "breeze", mapName: "Breeze"),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "bind", mapName: "Bind"),
                            ),
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "split", mapName: "Split"),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "haven", mapName: "Haven"),
                            ),
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "sunset", mapName: "Sunset"),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "fracture", mapName: "Fracture"),
                            ),
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "lotus", mapName: "Lotus"),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "icebox", mapName: "Icebox"),
                            ),
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "pearl", mapName: "Pearl"),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MapSelectButton(
                                  pageName: "abyss", mapName: "Abyss"),
                            ),
                            Expanded(
                              child: MapSelectButton(
                                  pageName: null, mapName: null),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (_showIntro) _buildIntroDialog(),
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

  Widget _buildIntroDialog() {
    return Center(
      child: AlertDialog(
        title: const Text('Save your tips!'),
        content: const IntrinsicHeight(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '''👆 Tap to add an icon at any position on the map.

📝 You can create a list of tips by entering text or a URL.

⚠️ Please enter only one URL in the content.

Supported URLs:
🖼️ Images (gif/png/jpg/jpeg)
🎥 Videos (mp4/avi/webm)
📺 YouTube (including shorts)
🌐 Other Websites

🗑️ Long press the icon to delete it.

🔍 Zoom the map using pinch gestures.

🐔 Enjoy!''',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _closeIntroDialog,
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
