import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDropdownButton extends StatefulWidget {
  final Function(String) onImageSelected;

  const CustomDropdownButton({super.key, required this.onImageSelected});

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  String? selectedImage;
  Future<List<String>>? imagePathsFuture;
  List<String> _customImagePaths = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    imagePathsFuture = _loadAssetImages('assets/images/icons/');
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _customImagePaths = _prefs.getStringList('customImagePaths') ?? [];
    });
  }

  Future<List<String>> _loadAssetImages(String assetPath) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final assetImages = manifestMap.keys
        .where((String key) => key.startsWith(assetPath))
        .toList();
    return assetImages;
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/${image.name}';
      await File(image.path).copy(path);

      setState(() {
        _customImagePaths.add(path);
      });
      _prefs.setStringList('customImagePaths', _customImagePaths);
      widget.onImageSelected(path);
    }
  }

  Future<void> _deleteImage(String path) async {
    final File file = File(path);
    if (await file.exists()) {
      await file.delete();
    }

    setState(() {
      _customImagePaths.remove(path);
    });
    _prefs.setStringList('customImagePaths', _customImagePaths);
  }

  void _showDeleteConfirmationDialog(String path) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete this icon?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _deleteImage(path);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showImagePickerDialog(List<String> imagePaths) {
    final allImagePaths = [...imagePaths, ..._customImagePaths];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: allImagePaths.length + 1,
              itemBuilder: (context, index) {
                if (index == allImagePaths.length) {
                  return GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 48,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }
                final imagePath = allImagePaths[index];
                final isAssetImage = imagePaths.contains(imagePath);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = imagePath;
                    });
                    widget.onImageSelected(imagePath);
                    Navigator.of(context).pop();
                  },
                  onLongPress: () {
                    if (!isAssetImage) {
                      _showDeleteConfirmationDialog(imagePath);
                    }
                  },
                  child: isAssetImage
                      ? Image.asset(
                          imagePath,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(imagePath),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: imagePathsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final imagePaths = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedImage != null)
                selectedImage!.startsWith('assets/')
                    ? Image.asset(
                        selectedImage!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(selectedImage!),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
              ElevatedButton(
                onPressed: () => _showImagePickerDialog(imagePaths),
                child: const Text('Select Type'),
              ),
            ],
          );
        }
      },
    );
  }
}
