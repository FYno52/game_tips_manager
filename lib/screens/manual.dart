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
              Color.fromARGB(255, 39, 125, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: const <Widget>[
              Section(
                title: 'How to Use This App',
                description: [
                  '1. Manage Your Tips Efficiently!',
                  '2. Adding Titles:\nOn the first page, add your favorite titles.',
                  '3. Creating a Tips List:\nOn the Tips page, create a tips list for the selected game.',
                  '4. Using the Tips Page:\nOn the tips page, first add an image.\nTap on the image to create a marker at the selected location.\nTap the created marker to display a list of tips for that location.',
                  '5. Viewing Details and URL Redirects:\nSelect an item to view details. If you entered a URL, you will be automatically redirected to the website.',
                  '6. Saving Text Notes:\nYou can also simply enter and save text notes.',
                  '7. Switching Between Tabs:\nSwitch between different tabs to organize your tips based on your needs.',
                  '8. Zooming the Image:\nUse pinch gestures to zoom the image.',
                  '9. Editing and Deleting Items:\nAll items can be edited or deleted by long pressing.',
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

  const Section({super.key, required this.title, required this.description});

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
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: description.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      description[index],
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
