import 'package:flutter/material.dart';

class CustomDropdownButton extends StatefulWidget {
  final Function(String) onImageSelected; // コールバック関数を追加

  const CustomDropdownButton({super.key, required this.onImageSelected});

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  String? selectedImage;

  List<String> imagePaths = [
    '',
    // 他の画像パスを追加
  ];

  void _showImagePickerDialog() {
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
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = imagePaths[index];
                    });
                    widget.onImageSelected(imagePaths[index]); // コールバック関数を呼び出す
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(imagePaths[index], width: 48, height: 48),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (selectedImage != null)
          Image.asset(selectedImage!, width: 48, height: 48),
        ElevatedButton(
          onPressed: _showImagePickerDialog,
          child: const Text('Select Agent'),
        ),
      ],
    );
  }
}
