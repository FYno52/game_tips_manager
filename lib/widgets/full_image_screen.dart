import 'package:flutter/material.dart';
import 'dart:io';

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;
  final String title;

  const FullScreenImagePage(
      {super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: InteractiveViewer(
        minScale: 0.1,
        maxScale: 4.0,
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
