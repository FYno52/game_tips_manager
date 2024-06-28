import 'dart:io';
import 'package:flutter/material.dart';
import 'package:game_tips_manager/ad_helper.dart';
import 'package:game_tips_manager/screens/map_page.dart';
import 'package:game_tips_manager/widgets/back_ground.dart';
import 'package:game_tips_manager/widgets/map_select_button.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class TipsStartScreen extends StatefulWidget {
  final String tipspageId;
  const TipsStartScreen({super.key, required this.tipspageId});

  @override
  _TipsStartScreenState createState() => _TipsStartScreenState();
}

class _TipsStartScreenState extends State<TipsStartScreen> {
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  final Uuid _uuid = const Uuid();
  bool isSortedByName = false;
  bool _isAscending = true;

  List<Map<String, String?>> _maps = [];

  @override
  void initState() {
    super.initState();
    _loadTopBannerAd();
    _loadBottomBannerAd();
    _loadMaps();
    _loadSortPreferences();
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
                decoration: const InputDecoration(labelText: 'Tips Title'),
                maxLength: 20,
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
    await prefs.setString('maps_${widget.tipspageId}', mapsJson);
  }

  Future<void> _loadMaps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mapsJson = prefs.getString('maps_${widget.tipspageId}');
    if (mapsJson != null) {
      List<dynamic> decodedMaps = json.decode(mapsJson);
      List<Map<String, String?>> typedMaps = decodedMaps.map((item) {
        return Map<String, String?>.from(item);
      }).toList();
      setState(() {
        _maps = typedMaps;
      });
    }
  }

  void _sortMaps(String criterion, {bool save = true, bool? ascending}) {
    setState(() {
      bool isAscending = ascending ?? _isAscending;
      if (criterion == 'name') {
        _maps.sort((a, b) =>
            a['mapName']!.compareTo(b['mapName']!) * (isAscending ? 1 : -1));
        isSortedByName = true;
      } else if (criterion == 'creation') {
        _maps.sort((a, b) =>
            a['pageId']!.compareTo(b['pageId']!) * (isAscending ? 1 : -1));
        isSortedByName = false;
      }
      _isAscending = isAscending;
    });
    if (save) {
      _saveSortPreferences();
    }
  }

  Future<void> _loadSortPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSortedByName =
        prefs.getBool('isSortedByName_${widget.tipspageId}') ?? false;
    _isAscending = prefs.getBool('isAscending_${widget.tipspageId}') ?? true;
    _sortMaps(isSortedByName ? 'name' : 'creation',
        save: false, ascending: _isAscending);
  }

  Future<void> _saveSortPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSortedByName_${widget.tipspageId}', isSortedByName);
    await prefs.setBool('isAscending_${widget.tipspageId}', _isAscending);
  }

  void _onSortSelected(String criterion) {
    if (isSortedByName == (criterion == 'name')) {
      // ソート基準が同じなら昇順/降順を反転
      _sortMaps(criterion, ascending: !_isAscending);
    } else {
      // ソート基準が違うならデフォルトの昇順でソート
      _sortMaps(criterion, ascending: true);
    }
  }

  Future<void> _showEditMapDialog(int index) async {
    String mapName = _maps[index]['mapName'] ?? '';
    XFile? imageFile;

    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      imageFile = await picker.pickImage(source: ImageSource.gallery);
    }

    Future<void> deleteMapData(String pageId) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('maps_$pageId');
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  mapName = value;
                },
                controller: TextEditingController(text: mapName),
                decoration: const InputDecoration(labelText: 'Tips Title'),
                maxLength: 20,
              ),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Select Image'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _maps[index] = {
                    'pageId': _maps[index]['pageId'],
                    'mapName': mapName,
                    'imageFile': imageFile?.path ?? _maps[index]['imageFile'],
                  };
                });
                _saveMaps(); // Save maps immediately after editing
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                bool? confirmDelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text(
                          'Are you sure you want to delete this tip?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Delete'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmDelete == true) {
                  setState(() {
                    deleteMapData(_maps[index]['pageId']!);
                    _maps.removeAt(index);
                  });
                  _saveMaps(); // Save maps immediately after deleting
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  Widget _buildMapButtons() {
    if (_maps.isEmpty) {
      return const Center(
        child: Text(
          'Add Tips',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    }

    List<Widget> rows = [];
    for (int i = 0; i < _maps.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onLongPress: () => _showEditMapDialog(i),
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
            ),
            if (i + 1 < _maps.length)
              Expanded(
                child: GestureDetector(
                  onLongPress: () => _showEditMapDialog(i + 1),
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 125, 255),
        title: const Text('Tips'),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PopupMenuButton<String>(
                  onSelected: _onSortSelected,
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'name',
                        child: Text(
                            'Sort by Name (${isSortedByName ? 'Asc' : 'Desc'})'),
                      ),
                      PopupMenuItem<String>(
                        value: 'creation',
                        child: Text(
                            'Sort by Creation (${_isAscending ? 'Asc' : 'Desc'})'),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.sort),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _showAddMapDialog,
                  child: const Text('Add Tips'),
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
    );
  }
}
