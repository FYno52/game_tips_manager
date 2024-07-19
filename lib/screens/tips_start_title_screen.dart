import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:game_tips_manager/ad_helper.dart';
import 'package:game_tips_manager/screens/tips_start_screen.dart';
import 'package:game_tips_manager/widgets/back_ground.dart';
import 'package:game_tips_manager/widgets/custom_drawer.dart';
import 'package:game_tips_manager/widgets/map_select_button.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
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
  BannerAd? _topBannerAd;
  final Uuid _uuid = const Uuid();
  bool isSortedByName = false;
  bool _isAscending = true;

  List<Map<String, String?>> _maps = [];

  @override
  void initState() {
    super.initState();
    _loadTopBannerAd();
    _loadMaps();
    _loadSortPreferences();
  }

  void _loadTopBannerAd() {
    BannerAd(
      adUnitId: AdHelper.titlesBannerAdUnitId,
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

  Future<String> _saveImageToFile(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${_uuid.v4()}.png';
    final File newImage = await File(image.path).copy(imagePath);
    return newImage.path;
  }

  Future<void> _showAddMapDialog() async {
    String mapName = '';
    XFile? imageFile;

    Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final String savedPath = await _saveImageToFile(pickedFile);
        setState(() {
          imageFile = XFile(savedPath);
        });
      }
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
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16), // ここで隙間を広げます
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
                ],
              ),
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
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final String savedPath = await _saveImageToFile(pickedFile);
        setState(() {
          imageFile = XFile(savedPath);
        });
      }
    }

    Future<void> deleteMapData(String pageId) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(pageId);
    }

    // Future<Map<String, dynamic>> _loadTipsData(String pageId) async {
    //   // TipsStartScreen に関連するデータを取得するための関数
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   String? tipsJson = prefs.getString(pageId);
    //   if (tipsJson != null) {
    //     return jsonDecode(tipsJson);
    //   }
    //   return {};
    // }

    // Future<void> _exportMapData(String fileName) async {
    //   await _requestStoragePermission();
    //   final status = await Permission.storage.status;
    //   if (status.isGranted) {
    //     try {
    //       final result = await FilePicker.platform.getDirectoryPath();
    //       if (result != null) {
    //         String path = '$result/$fileName.json';
    //         int count = 1;
    //         while (File(path).existsSync()) {
    //           path = '$result/$fileName($count).json';
    //           count++;
    //         }
    //         final file = File(path);
    //         final exportData = Map<String, dynamic>.from(
    //             _maps[index]); // 型をMap<String, dynamic>に変換

    //         // 各タイトルページのデータに関連する TipsStartScreen のデータを追加
    //         final tipsData = await _loadTipsData(exportData['pageId']!);
    //         exportData['tipsData'] = tipsData;

    //         await file.writeAsString(jsonEncode(exportData));
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text('Data exported successfully to $path')),
    //         );
    //       } else {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           const SnackBar(content: Text('Failed to get export directory')),
    //         );
    //       }
    //     } catch (e) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('Failed to export data: ${e.toString()}')),
    //       );
    //     }
    //   } else {
    //     final shouldOpenSettings = await showDialog<bool>(
    //           context: context,
    //           builder: (context) => AlertDialog(
    //             title: const Text('Storage Permission Required'),
    //             content: const Text(
    //                 'Storage permission is required to export data. Please grant the permission.'),
    //             actions: [
    //               TextButton(
    //                 onPressed: () => Navigator.of(context).pop(false),
    //                 child: const Text('Cancel'),
    //               ),
    //               TextButton(
    //                 onPressed: () => Navigator.of(context).pop(true),
    //                 child: const Text('Grant Permission'),
    //               ),
    //             ],
    //           ),
    //         ) ??
    //         false;

    //     if (shouldOpenSettings) {
    //       openAppSettings();
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Storage permission denied')),
    //       );
    //     }
    //   }
    // }

    // Future<void> _requestExportFileName() async {
    //   final TextEditingController fileNameController = TextEditingController();

    //   final bool confirmed = await showDialog<bool>(
    //         context: context,
    //         builder: (context) => AlertDialog(
    //           title: const Text('Export This Title File'),
    //           content: TextField(
    //             controller: fileNameController,
    //             decoration: const InputDecoration(hintText: 'Enter file name'),
    //           ),
    //           actions: [
    //             TextButton(
    //               onPressed: () => Navigator.of(context).pop(false),
    //               child: const Text('Cancel'),
    //             ),
    //             TextButton(
    //               onPressed: () => Navigator.of(context).pop(true),
    //               child: const Text('Save'),
    //             ),
    //           ],
    //         ),
    //       ) ??
    //       false;

    //   if (confirmed && fileNameController.text.isNotEmpty) {
    //     await _exportMapData(fileNameController.text);
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('File name cannot be empty')),
    //     );
    //   }
    // }

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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // IconButton(
                //   icon: const Icon(Icons.file_download),
                //   onPressed: _requestExportFileName,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final bool? confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this title file?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true) {
                          deleteMapData(_maps[index]['pageId']!);
                          setState(() {
                            _maps.removeAt(index);
                          });
                          _saveMaps();
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Delete'),
                    ),
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
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Future<void> _requestStoragePermission() async {
  //   await Permission.storage.request();
  // }

  @override
  void dispose() {
    _topBannerAd?.dispose();
    // _bottomBannerAd?.dispose();
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
                // const SizedBox(width: 8),
                // ElevatedButton(
                //   onPressed: _importMapData,
                //   child: const Text('Import Data'),
                // ),
                // const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _showAddMapDialog,
                  child: const Text('Add Titles'),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
    );
  }

  // データをエクスポート・インポートする関数

  // Future<void> _importMapData() async {
  //   await _requestStoragePermission();
  //   final status = await Permission.storage.status;
  //   if (status.isGranted) {
  //     try {
  //       final result = await FilePicker.platform
  //           .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
  //       if (result != null && result.files.single.path != null) {
  //         final path = result.files.single.path!;
  //         final file = File(path);
  //         final contents = await file.readAsString();
  //         final Map<String, dynamic> jsonData = jsonDecode(contents);

  //         // jsonDataをMap<String, String?>に変換
  //         final Map<String, String?> importedData = jsonData.map((key, value) {
  //           if (value is String || value == null) {
  //             return MapEntry(key, value);
  //           } else {
  //             return MapEntry(key, value.toString());
  //           }
  //         });

  //         // インポートしたデータを利用する
  //         setState(() {
  //           _maps.add(importedData);
  //         });

  //         // TipsDataのインポート
  //         if (jsonData['tipsData'] != null) {
  //           SharedPreferences prefs = await SharedPreferences.getInstance();
  //           await prefs.setString(
  //               importedData['pageId']!, jsonEncode(jsonData['tipsData']));
  //         }

  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Data imported successfully')),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Failed to pick a file')),
  //         );
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to import data: ${e.toString()}')),
  //       );
  //     }
  //   } else {
  //     final shouldOpenSettings = await showDialog<bool>(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: const Text('Storage Permission Required'),
  //             content: const Text(
  //                 'Storage permission is required to import data. Please grant the permission.'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(false),
  //                 child: const Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(true),
  //                 child: const Text('Grant Permission'),
  //               ),
  //             ],
  //           ),
  //         ) ??
  //         false;

  //     if (shouldOpenSettings) {
  //       openAppSettings();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Storage permission denied')),
  //       );
  //     }
  //   }
  // }
}
