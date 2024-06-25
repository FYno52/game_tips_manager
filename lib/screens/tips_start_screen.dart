import 'dart:io';
import 'package:flutter/material.dart';
import 'package:game_tips_manager/ad_helper.dart';
import 'package:game_tips_manager/screens/map_page.dart';
import 'package:game_tips_manager/widgets/back_ground.dart';
import 'package:game_tips_manager/widgets/custom_drawer.dart';
import 'package:game_tips_manager/widgets/map_select_button.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class TipsStartScreen extends StatefulWidget {
  const TipsStartScreen({super.key});

  @override
  _TipsStartScreenState createState() => _TipsStartScreenState();
}

class _TipsStartScreenState extends State<TipsStartScreen> {
  bool _showIntro = false;
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  final Uuid _uuid = const Uuid();

  List<Map<String, String?>> _maps = [];

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _loadTopBannerAd();
    _loadBottomBannerAd();
    _loadMaps();
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

  Future<void> _showAddMapDialog() async {
    String mapName = '';
    XFile? imageFile;

    Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      imageFile = await picker.pickImage(source: ImageSource.gallery);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tips Page'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  mapName = value;
                },
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Image'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final String pageId = _uuid.v4();
                setState(() {
                  _maps.add({
                    'pageId': pageId,
                    'mapName': mapName,
                    'imageFile': imageFile?.path,
                  });
                });
                _saveMaps(); // Save maps immediately after adding
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveMaps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String mapsJson = json.encode(_maps);
    await prefs.setString('maps', mapsJson);
  }

  Future<void> _loadMaps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mapsJson = prefs.getString('maps');
    if (mapsJson != null) {
      setState(() {
        _maps = List<Map<String, String?>>.from(json.decode(mapsJson));
      });
    }
  }

  @override
  void dispose() {
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  Widget _buildMapButtons() {
    List<Widget> rows = [];
    for (int i = 0; i < _maps.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(
              child: MapSelectButton(
                mapName: _maps[i]['mapName'],
                imageFile: _maps[i]['imageFile'] != null &&
                        _maps[i]['imageFile']!.isNotEmpty
                    ? File(_maps[i]['imageFile']!)
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MapPage(pageId: _maps[i]['pageId']!), // pageIdを使用
                    ),
                  );
                },
              ),
            ),
            if (i + 1 < _maps.length)
              Expanded(
                child: MapSelectButton(
                  mapName: _maps[i + 1]['mapName'],
                  imageFile: _maps[i + 1]['imageFile'] != null &&
                          _maps[i + 1]['imageFile']!.isNotEmpty
                      ? File(_maps[i + 1]['imageFile']!)
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(
                            pageId: _maps[i + 1]['pageId']!), // pageIdを使用
                      ),
                    );
                  },
                ),
              )
            else
              Expanded(child: Container()),
          ],
        ),
      );
    }
    return Column(children: rows);
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
                BackGround(
                  children: [
                    Column(
                      children: [
                        _buildMapButtons(),
                      ],
                    ),
                  ],
                ),
                if (_showIntro) _buildIntroDialog(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showAddMapDialog,
              child: const Text('Add Tips'),
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
