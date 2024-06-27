import 'dart:io';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:game_tips_manager/ad_helper.dart';
import 'package:game_tips_manager/widgets/custom_dropdown_button.dart';
import 'package:game_tips_manager/widgets/full_image_screen.dart';
import 'package:game_tips_manager/widgets/video_player.dart';
import 'package:game_tips_manager/widgets/web_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:convert';

class MapPage extends StatefulWidget {
  final String pageId;

  const MapPage({
    super.key,
    required this.pageId,
  });

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Map<String, dynamic>> _icons = [];
  List<Map<String, dynamic>> _iconsTab1 = [];
  List<Map<String, dynamic>> _iconsTab2 = [];
  List<Map<String, dynamic>> _iconsTab3 = [];
  List<Map<String, dynamic>> _iconsTab4 = [];
  int _currentTabIndex = 0;
  final GlobalKey _stackKey = GlobalKey();
  double _imageWidth = 1.0;
  double _imageHeight = 1.0;
  bool _isImageLoaded = false;

  File? _imageFile;
  static const String _imagePathKey = 'selectedImagePath';

  static const String _iconColorKey = 'iconColor';
  Color _iconColor = const Color.fromARGB(255, 243, 243, 243);

  static const String _backgroundColorKey = 'backgroundColor';
  Color _backgroundColor = const Color.fromARGB(255, 0, 0, 0);

  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;
  BannerAd? _memoListBannerAd;

  @override
  void initState() {
    super.initState();
    _loadIcons();
    _loadImagePath();
    _loadTopBannerAd();
    _loadBottomBannerAd();
    _loadMemoListBannerAd();
    _loadIconColor();
    _loadBackgroundColor();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isImageLoaded = false; // Reset the flag when a new image is picked
        _saveImagePath(pickedFile.path); // Save the new image path
      });
    }
  }

  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_imagePathKey}_${widget.pageId}', path);
  }

  Future<void> _loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('${_imagePathKey}_${widget.pageId}');

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _imageFile = File(imagePath);
        _isImageLoaded = false; // Reset the flag when the image is loaded
      });
    }
  }

  Future<void> _saveIconColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_iconColorKey}_${widget.pageId}', color.value);
  }

  Future<void> _loadIconColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('${_iconColorKey}_${widget.pageId}');

    if (colorValue != null) {
      setState(() {
        _iconColor = Color(colorValue);
      });
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: _iconColor,
              onColorChanged: (color) {
                setState(() {
                  _iconColor = color;
                });
                _saveIconColor(color);
              },
              heading: const Text(
                'Select color',
              ),
              subheading: const Text(
                'Select color shade',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadIcons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _iconsTab1 = List<Map<String, dynamic>>.from(
          json.decode(prefs.getString('icons_${widget.pageId}_tab1') ?? '[]'));
      _iconsTab2 = List<Map<String, dynamic>>.from(
          json.decode(prefs.getString('icons_${widget.pageId}_tab2') ?? '[]'));
      _iconsTab3 = List<Map<String, dynamic>>.from(
          json.decode(prefs.getString('icons_${widget.pageId}_tab3') ?? '[]'));
      _iconsTab4 = List<Map<String, dynamic>>.from(
          json.decode(prefs.getString('icons_${widget.pageId}_tab4') ?? '[]'));
      _icons = _iconsTab1;
    });
  }

  Future<void> _saveIcons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('icons_${widget.pageId}_tab1', json.encode(_iconsTab1));
    prefs.setString('icons_${widget.pageId}_tab2', json.encode(_iconsTab2));
    prefs.setString('icons_${widget.pageId}_tab3', json.encode(_iconsTab3));
    prefs.setString('icons_${widget.pageId}_tab4', json.encode(_iconsTab4));
  }

  Future<void> _saveBackgroundColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_backgroundColorKey}_${widget.pageId}', color.value);
  }

  Future<void> _loadBackgroundColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('${_backgroundColorKey}_${widget.pageId}');

    if (colorValue != null) {
      setState(() {
        _backgroundColor = Color(colorValue);
      });
    }
  }

  void _pickBackgroundColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a background color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: _backgroundColor,
              onColorChanged: (color) {
                setState(() {
                  _backgroundColor = color;
                });
                _saveBackgroundColor(color);
              },
              heading: const Text(
                'Select color',
              ),
              subheading: const Text(
                'Select color shade',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addIcon(TapUpDetails details) async {
    Map<String, dynamic>? memo = await _showAddMemoDialog();
    if (memo != null) {
      setState(() {
        final RenderBox box =
            _stackKey.currentContext!.findRenderObject() as RenderBox;
        final position = box.globalToLocal(details.globalPosition);
        final normalizedX = position.dx / _imageWidth;
        final normalizedY = position.dy / _imageHeight;
        _icons.add({
          'x': normalizedX,
          'y': normalizedY,
          'memos': [memo] // Initialize with the first memo
        });
        _saveIcons();
      });
    }
  }

  Future<Map<String, dynamic>?> _showAddMemoDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    String selectedImage = 'assets/images/icons/Default_icon.png';
    File? imageFile;

    Future<void> pickImage() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    }

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add', style: TextStyle(fontSize: 18)),
                CustomDropdownButton(
                  onImageSelected: (String imagePath) {
                    setState(() {
                      selectedImage = imagePath;
                    });
                  },
                ),
                TextField(
                  controller: titleController,
                  decoration:
                      const InputDecoration(hintText: 'Enter title here'),
                  maxLength: 40,
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                      hintText:
                          'Enter content here.\nIf entering a URL, please use only one.\nIf uploading an image, it will not automatically redirect.'),
                  maxLines: 5,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text('Pick Image'),
                ),
                if (imageFile != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                      maxHeight: 300,
                    ),
                    child: Image.file(imageFile!),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        final memo = {
                          'title': titleController.text,
                          'content': contentController.text,
                          'imagePath': selectedImage,
                        };
                        if (imageFile != null) {
                          memo['imageFile'] = imageFile!.path;
                        }
                        Navigator.of(context).pop(memo);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteIcon(int index) {
    setState(() {
      _icons.removeAt(index);
      _saveIcons();
    });
  }

  Future<void> _confirmDelete(int index) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Icon'),
        content: const Text('Are you sure you want to delete this icon?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _deleteIcon(index);
    }
  }

  Future<bool?> _showDeleteConfirmDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Are you sure you want to delete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _showEditMemoDialog(
      Map<String, dynamic> memo) async {
    TextEditingController titleController =
        TextEditingController(text: memo['title']);
    TextEditingController contentController =
        TextEditingController(text: memo['content']);
    String selectedImage =
        memo['imagePath'] ?? 'assets/images/face_icons/Default_icon.png';
    File? imageFile;

    Future<void> pickImage() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    }

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit',
                  style: TextStyle(fontSize: 18),
                ),
                CustomDropdownButton(
                  onImageSelected: (String imagePath) {
                    selectedImage = imagePath;
                  },
                ),
                TextField(
                  controller: titleController,
                  decoration:
                      const InputDecoration(hintText: 'Enter title here'),
                  maxLength: 40,
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                      hintText:
                          'Enter content here.\nIf entering a URL, please use only one.\nIf uploading an image, it will not automatically redirect.'),
                  maxLines: 5,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text('Pick Image'),
                ),
                if (imageFile != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                      maxHeight: 300,
                    ),
                    child: Image.file(imageFile!),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final editedMemo = {
                          'title': titleController.text,
                          'content': contentController.text,
                          'imagePath': selectedImage,
                        };
                        if (imageFile != null) {
                          editedMemo['imageFile'] = imageFile!.path;
                        } else if (memo.containsKey('imageFile')) {
                          editedMemo['imageFile'] = memo['imageFile'];
                        }
                        Navigator.of(context).pop(editedMemo);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMemoList(int iconIndex) async {
    List<dynamic> memos = List<dynamic>.from(_icons[iconIndex]['memos']);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return FractionallySizedBox(
            heightFactor: 0.8, // 高さを画面の80%に設定
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_memoListBannerAd != null)
                  SizedBox(
                    width: _memoListBannerAd!.size.width.toDouble(),
                    height: _memoListBannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _memoListBannerAd!),
                  ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: memos.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> memo = memos[index];
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ListTile(
                          leading: memo.containsKey('imagePath')
                              ? (memo['imagePath'].startsWith('assets/')
                                  ? Image.asset(
                                      memo['imagePath'],
                                      width: 32,
                                      height: 32,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // デフォルトのアイコンにフォールバック
                                        return Image.asset(
                                          'assets/images/icons/Default_icon.png',
                                          width: 32,
                                          height: 32,
                                        );
                                      },
                                    )
                                  : Image.file(
                                      File(memo['imagePath']),
                                      width: 32,
                                      height: 32,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // デフォルトのアイコンにフォールバック
                                        return Image.asset(
                                          'assets/images/icons/Default_icon.png',
                                          width: 32,
                                          height: 32,
                                        );
                                      },
                                    ))
                              : Image.asset(
                                  'assets/images/icons/Default_icon.png',
                                  width: 32,
                                  height: 32,
                                ),
                          title: Text(memo['title']!),
                          onTap: () {
                            _showMemo(memo);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                iconSize: 20,
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  Map<String, dynamic>? editedMemo =
                                      await _showEditMemoDialog(memo);
                                  if (editedMemo != null) {
                                    setState(() {
                                      memos[index] = editedMemo;
                                      _icons[iconIndex]['memos'] = memos;
                                      _saveIcons();
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                iconSize: 20,
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  bool? confirm =
                                      await _showDeleteConfirmDialog();
                                  if (confirm == true) {
                                    setState(() {
                                      memos.removeAt(index);
                                      _icons[iconIndex]['memos'] = memos;
                                      _saveIcons();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic>? newMemo =
                          await _showAddMemoDialog();
                      if (newMemo != null) {
                        setState(() {
                          memos.add(newMemo);
                          _icons[iconIndex]['memos'] = memos;
                          _saveIcons();
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMemo(Map<String, dynamic> memo) {
    final content = memo['content']!;
    final imageFile = memo['imageFile'];

    if (imageFile != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(memo['title']!),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FullScreenImagePage(
                          imagePath: imageFile,
                          title: memo['title'],
                        ),
                      ),
                    );
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: Image.file(File(imageFile)),
                  ),
                ),
                const SizedBox(
                    height:
                        10), // Add some space between the image and the text
                Text(content),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else if (content.endsWith('.mp4') ||
        content.endsWith('.webm') ||
        content.endsWith('.avi')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoUrl: content,
            title: memo['title'],
          ),
        ),
      );
    } else if (content.contains('https://') || content.contains('http//')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebView(
            url: content,
            title: memo['title'],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(memo['title']!),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(content),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
      switch (_currentTabIndex) {
        case 0:
          _icons = _iconsTab1;
          break;
        case 1:
          _icons = _iconsTab2;
          break;
        case 2:
          _icons = _iconsTab3;
          break;
        case 3:
          _icons = _iconsTab4;
          break;
      }
    });
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

  Future<void> _loadMemoListBannerAd() async {
    _memoListBannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _memoListBannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          setState(() {
            _memoListBannerAd = null;
          });
        },
      ),
    );
    await _memoListBannerAd?.load();
  }

  @override
  void dispose() {
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    _memoListBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 39, 125, 255),
          title: const Text('Tap to add / Longpress to delete'),
          bottom: TabBar(
            onTap: _onTabChanged,
            tabs: const [
              Tab(text: 'Tab1'),
              Tab(text: 'Tab2'),
              Tab(text: 'Tab3'),
              Tab(text: 'Tab4'),
            ],
            indicatorColor: Colors.white, // Change the indicator color
            labelColor: Colors.white, // Change the color of the selected tab
            unselectedLabelColor:
                Colors.black, // Change the color of the unselected tab
          ),
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
              child: InteractiveViewer(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _backgroundColor, // 単色で背景色を設定
                      ),
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final imageSize =
                                constraints.maxWidth < constraints.maxHeight
                                    ? constraints.maxWidth
                                    : constraints.maxHeight;
                            return Stack(
                              key: _stackKey,
                              children: [
                                if (_imageFile != null)
                                  GestureDetector(
                                    onTapUp: _addIcon,
                                    child: Image.file(
                                      _imageFile!,
                                      width: imageSize,
                                      height: imageSize,
                                      fit: BoxFit.contain,
                                      key: _stackKey,
                                      frameBuilder: (context, child, frame,
                                          wasSynchronouslyLoaded) {
                                        if (frame != null) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            final RenderBox box = _stackKey
                                                    .currentContext!
                                                    .findRenderObject()
                                                as RenderBox;
                                            final size = box.size;
                                            setState(() {
                                              _imageWidth = size.width;
                                              _imageHeight = size.height;
                                              _isImageLoaded = true;
                                            });
                                          });
                                        }
                                        return child;
                                      },
                                    ),
                                  )
                                else
                                  const Center(
                                    child: Text(
                                      'Please set the image first.',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                    ),
                                  ),
                                if (_isImageLoaded)
                                  ..._icons.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    Map<String, dynamic> icon = entry.value;
                                    return Positioned(
                                      left: icon['x'] * _imageWidth -
                                          12, // Adjust by half the icon width
                                      top: icon['y'] * _imageHeight -
                                          22, // Adjust by half the icon height
                                      child: GestureDetector(
                                        onTap: () => _showMemoList(index),
                                        onLongPress: () =>
                                            _confirmDelete(index),
                                        child: Icon(
                                          Icons.location_on,
                                          color: _iconColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: ElevatedButton(
                    onPressed: _pickColor,
                    child: const Text('Marker Color'),
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: _pickBackgroundColor,
                    child: const Text('Background Color'),
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Set Image'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: AdSize.banner.width.toDouble(),
              height: AdSize.banner.height.toDouble(),
              child: _bottomBannerAd != null
                  ? AdWidget(ad: _bottomBannerAd!)
                  : Container(color: Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}
