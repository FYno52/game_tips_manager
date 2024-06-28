import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 125, 255),
        title: const Text('Manual'),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 121, 190, 255),
            Color.fromARGB(255, 39, 125, 255)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: Center(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: const <Widget>[
              Section(
                title: 'Create Tips Mode',
                description: [
                  'Manage your tips efficiently!',
                  'On the first page add your favorite titles.',
                  'On the next page, create a tips list for that game.',
                  'On the tip page, first add the image.',
                  'Tap on the image to create a marker at the selected location.',
                  'Tap the created marker to display a list of tips for that location.',
                  'Select an item to view details. If you entered a URL, you will be automatically redirected to the website.',
                  'You can also simply enter and save text notes!',
                  'Switch between different tabs to organize your tips based on your needs.',
                  'Zoom the image using pinch gestures.',
                  'All items can be edited or deleted by long pressing.'
                ],
              ),

              // 必要に応じて他のセクションを追加
            ],
          ),
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<String> description;

  const Section({Key? key, required this.title, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ...description.map((line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    '- $line',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
