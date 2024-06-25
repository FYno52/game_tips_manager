import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class MapSelectButton extends StatelessWidget {
  final String? pageName;
  final String? mapName; //画像の名前がそのままボタンに反映されるので注意
  final File? imageFile; // 画像のファイルパスを追加

  const MapSelectButton({
    super.key,
    this.pageName,
    this.mapName,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the height based on the available width to maintain the aspect ratio
        double height =
            constraints.maxWidth / 1.7; // Adjust the aspect ratio as needed

        return InkWell(
          onTap: () {
            if (pageName != null) {
              context.pushNamed(pageName!);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            height: height,
            child: Stack(
              children: [
                if (imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                      width: constraints.maxWidth,
                      height: height,
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: constraints.maxWidth,
                    height: height,
                  ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      mapName ?? 'None', // Default text
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: constraints.maxWidth *
                            0.17, // Adjust font size based on width
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
