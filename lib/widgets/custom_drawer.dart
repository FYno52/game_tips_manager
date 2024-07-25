import 'package:flutter/material.dart';
import 'package:game_tips_manager/screens/manual.dart';
import 'package:game_tips_manager/screens/privacy_policy_screen.dart';
import 'package:game_tips_manager/screens/terms_of_service_screen.dart';
import 'package:game_tips_manager/screens/tips_start_title_screen.dart';
import 'package:game_tips_manager/screens/tutorial_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 121, 190, 255),
                Color.fromARGB(255, 39, 125, 255)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tips_and_updates),
            title: const Text('Create Your Tips'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TipsStartTitleScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.slideshow),
            title: const Text('How to Use'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TutorialPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Manual'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManualPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Terms Of Service'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TermsOfServiceScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
