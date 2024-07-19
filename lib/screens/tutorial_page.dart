import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  Widget _buildIntroContent() {
    PageController pageController = PageController();

    Widget buildPageContent(String content, {String? imagePath}) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imagePath != null)
                  Image.asset(imagePath, height: 300, fit: BoxFit.contain),
                if (imagePath != null) const SizedBox(height: 12),
                Text(
                  content,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    List<Map<String, String?>> pages = [
      {
        'content':
            '''👆 Switch between different tabs to organize your tips based on your needs.''',
        'image': 'assets/images/tutorial/tab.png',
      },
      {
        'content':
            '''👆 Tap to add a marker at any position on the map.\n\n🤏 Zoom the map using pinch gestures.''',
        'image': 'assets/images/tutorial/map.png',
      },
      {
        'content':
            '''👆 Tap the marker to open the memo list.\n\n🗑️ Long press the marker to delete all items it contains.''',
        'image': 'assets/images/tutorial/marker.png',
      },
      {
        'content':
            '''📝 Create a memo list by adding notes with text or URLs.''',
        'image': 'assets/images/tutorial/memo_list.png',
      },
      {
        'content':
            '''🔗 Entering only a URL will automatically redirect.\n\n⚡ Quickly access your favorite page and content!''',
        'image': 'assets/images/tutorial/web.png',
      },
      {
        'content':
            '''Supported URLs:\n📺 YouTube (including shorts)\n🐦 X(Twitter)\n🌐 Other Websites''',
        'image': 'assets/images/tutorial/web2.png',
      },
      {
        'content':
            '''Supported URLs:\n🎥 Videos (mp4/avi/webm)\n🖼️ Images (gif/png/jpg/jpeg)''',
        'image': 'assets/images/tutorial/movie.png',
      },
      {
        'content':
            '''📤 Share tips data on the map with friends.\n\n⚠️ Uploaded images cannot be shared.''',
        'image': 'assets/images/tutorial/file.png',
      },
      {
        'content': '''\n\n\n\n\n\n🐔 Enjoy! 🐔''',
        'image': null, // 最後のページは画像なし
      },
    ];

    return Container(
      color: Colors.white, // 背景色を設定
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '⬅️ Please Swipe ➡️', // タイトルを追加
                        style: TextStyle(
                          fontSize: 24,
                          // fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // タイトルを中央揃え
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 500,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: buildPageContent(
                          pages[index]['content']!,
                          imagePath: pages[index]['image'],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 48),
                SmoothPageIndicator(
                  controller: pageController, // PageController
                  count: pages.length,
                  effect: const WormEffect(), // ここでインジケーターのスタイルを指定
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(centerTitle: true, title: const Text('How to Use This App')),
      body: _buildIntroContent(),
    );
  }
}
