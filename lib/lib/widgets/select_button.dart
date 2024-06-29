import 'package:flutter/material.dart';

class SelectButton extends StatelessWidget {
  final String text;
  final Widget destinationPage;

  const SelectButton(
      {super.key, required this.text, required this.destinationPage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the height based on the available width to maintain the aspect ratio
        double height =
            constraints.maxWidth / 1.8; // Adjust the aspect ratio as needed

        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            height: height,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/images/start_page/Intro_$text.jpg',
                    fit: BoxFit.cover,
                    width: constraints.maxWidth,
                    height: height,
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: constraints.maxWidth *
                            0.12, // Adjust font size based on width
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
