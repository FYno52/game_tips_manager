import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:game_tips_manager/ad_helper.dart';
import 'package:game_tips_manager/screens/tips_start_screen.dart';
import 'package:game_tips_manager/widgets/back_ground.dart';
import 'package:game_tips_manager/widgets/custom_drawer.dart';
import 'package:game_tips_manager/widgets/map_select_button.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class TipsStartTitleScreen extends StatefulWidget {
  const TipsStartTitleScreen({
    super.key,
  });

  @override
  _TipsStartTitleScreenState createState() => _TipsStartTitleScreenState();
}

class _TipsStartTitleScreenState extends State<TipsStartTitleScreen> {
  bool _showIntro = false;
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  final Uuid _uuid = const Uuid();
  bool isSortedByName = false;
  bool _isAscending = true;

  List<Map<String, String?>> _maps = [];

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _loadTopBannerAd();
    _loadBottomBannerAd();
    _loadMaps();
    _loadSortPreferences();
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

  // void _closeIntroDialog() {
  //   setState(() {
  //     _showIntro = false;
  //   });
  // }

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
          title: const Text('Add Title Page'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  mapName = value;
                },
                decoration: const InputDecoration(labelText: 'Game Title'),
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
                final String titlePageId = _uuid.v4();
                setState(() {
                  _maps.add({
                    'pageId': titlePageId,
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
    String titlesJson = json.encode(_maps);
    await prefs.setString('titles', titlesJson);
  }

  Future<void> _loadMaps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? titlesJson = prefs.getString('titles');
    if (titlesJson != null) {
      List<dynamic> decodedMaps = json.decode(titlesJson);
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
    isSortedByName = prefs.getBool('isSortedByName') ?? false;
    _isAscending = prefs.getBool('isAscending') ?? true;
    _sortMaps(isSortedByName ? 'name' : 'creation',
        save: false, ascending: _isAscending);
  }

  Future<void> _saveSortPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSortedByName', isSortedByName);
    await prefs.setBool('isAscending', _isAscending);
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
      await prefs.remove(pageId);
    }

    Future<void> _exportMapData(String fileName) async {
      await _requestStoragePermission();
      final status = await Permission.storage.status;
      if (status.isGranted) {
        try {
          final result = await FilePicker.platform.getDirectoryPath();
          if (result != null) {
            String path = '$result/$fileName.json';
            int count = 1;
            while (File(path).existsSync()) {
              path = '$result/$fileName($count).json';
              count++;
            }
            final file = File(path);
            final exportData = _maps[index];
            await file.writeAsString(jsonEncode(exportData));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data exported successfully to $path')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to get export directory')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to export data: ${e.toString()}')),
          );
        }
      } else {
        final shouldOpenSettings = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Storage Permission Required'),
                content: const Text(
                    'Storage permission is required to export data. Please grant the permission.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldOpenSettings) {
          openAppSettings();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
      }
    }

    Future<void> _requestExportFileName() async {
      final TextEditingController fileNameController = TextEditingController();

      final bool confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Enter File Name'),
              content: TextField(
                controller: fileNameController,
                decoration: const InputDecoration(hintText: 'Enter file name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Save'),
                ),
              ],
            ),
          ) ??
          false;

      if (confirmed && fileNameController.text.isNotEmpty) {
        await _exportMapData(fileNameController.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File name cannot be empty')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Title Page'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  mapName = value;
                },
                controller: TextEditingController(text: mapName),
                decoration: const InputDecoration(labelText: 'Game Title'),
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
                  _maps[index]['mapName'] = mapName;
                  if (imageFile != null) {
                    _maps[index]['imageFile'] = imageFile?.path;
                  }
                });
                _saveMaps(); // Save maps immediately after editing
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                deleteMapData(_maps[index]['pageId']!);
                setState(() {
                  _maps.removeAt(index);
                });
                _saveMaps();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: _requestExportFileName,
              child: const Text('Export'),
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

  Future<void> _requestStoragePermission() async {
    await Permission.storage.request();
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
          'Add Game Title',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    }

    List<Widget> columns = [];
    for (int i = 0; i < _maps.length; i++) {
      columns.add(
        Container(
          margin: const EdgeInsets.only(bottom: 5), // 各アイテム間にスペースを追加
          width: double.infinity, // 横幅を画面いっぱいに広げる
          height: 100, // 必要に応じて高さを調整
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
                    builder: (context) => TipsStartScreen(
                        tipspageId: _maps[i]['pageId']!), // pageIdを使用
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
    return Column(
      children: columns,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 125, 255),
        title: const Text('Game Titles'),
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
                if (_showIntro) _buildIntroContent(),
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
                  child: const Text('Add Titles'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _importData,
                  child: const Text('Import Data'),
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

  void _hideIntroContent() {
    setState(() {
      _showIntro = false;
    });
  }

  Widget _buildIntroContent() {
    return Container(
      color: Colors.white, // 背景色を設定
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _hideIntroContent,
                    ),
                    const Expanded(
                      child: Text(
                        'How to Use This App', // タイトルを追加
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // タイトルを中央揃え
                      ),
                    ),
                    const SizedBox(width: 48), // アイコンのサイズと同じスペースを確保
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '''➕ Add your favorite game titles and create your own tips!.

👆 Tap to add a marker at any position on the image.

📝 You can create a list of tips by entering text or a URL.

🔗 Entering only a URL will automatically redirect.

Supported URLs:
🖼️ Images (gif/png/jpg/jpeg)
🎥 Videos (mp4/avi/webm)
📺 YouTube (including shorts)
🌐 Other Websites

🗑️ Long press to edit or delete all items.

🔍 Zoom the image using pinch gestures.

🐔 Enjoy!''',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _hideIntroContent,
                  child: const Text('Got it'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // データをエクスポート・インポートする関数

  Future<void> _confirmExport() async {
    final bool shouldExport = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Export'),
            content:
                const Text('Are you sure you want to export the current data?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Export'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldExport) {
      await _requestExportFileName();
    }
  }

  Future<void> _requestExportFileName() async {
    final TextEditingController fileNameController = TextEditingController();

    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enter File Name'),
            content: TextField(
              controller: fileNameController,
              decoration: const InputDecoration(hintText: 'Enter file name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && fileNameController.text.isNotEmpty) {
      await _exportData(fileNameController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File name cannot be empty')),
      );
    }
  }

  Future<void> _exportData(String fileName) async {
    await _requestStoragePermission();
    final status = await Permission.storage.status;
    if (status.isGranted) {
      try {
        final result = await FilePicker.platform.getDirectoryPath();
        if (result != null) {
          String path = '$result/$fileName.json';
          int count = 1;
          while (File(path).existsSync()) {
            path = '$result/$fileName($count).json';
            count++;
          }
          final file = File(path);
          await file.writeAsString(jsonEncode(_maps));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data exported successfully to $path')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get export directory')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: ${e.toString()}')),
        );
      }
    } else {
      final shouldOpenSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Storage Permission Required'),
              content: const Text(
                  'Storage permission is required to export data. Please grant the permission.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Grant Permission'),
                ),
              ],
            ),
          ) ??
          false;

      if (shouldOpenSettings) {
        openAppSettings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    }
  }

  Future<void> _confirmImport(String path) async {
    final bool shouldImport = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Import'),
            content: const Text(
                'Importing will overwrite your current data. Do you want to continue?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldImport) {
      final file = File(path);
      final data = jsonDecode(await file.readAsString());
      setState(() {
        _maps = List<Map<String, String?>>.from(data);
      });
      _saveMaps();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data imported successfully from ${file.path}')),
      );
    }
  }

  Future<void> _importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        String? path = result.files.single.path;
        if (path != null && await File(path).exists()) {
          String jsonData = await File(path).readAsString();
          Map<String, dynamic> importMap = json.decode(jsonData);

          // マップデータに追加する
          setState(() {
            _maps.add(Map<String, String?>.from(importMap));
          });

          _saveMaps(); // 保存
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data imported successfully from $path')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File does not exist')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import data: ${e.toString()}')),
      );
    }
  }
}
