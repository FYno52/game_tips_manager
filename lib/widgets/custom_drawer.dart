import 'package:flutter/material.dart';
import 'package:game_tips_manager/screens/manual.dart';
import 'package:game_tips_manager/screens/privacy_policy_screen.dart';
import 'package:game_tips_manager/screens/terms_of_service_screen.dart';
import 'package:go_router/go_router.dart';

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
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => context.pushNamed('home'),
          ),
          ListTile(
            leading: const Icon(Icons.fire_extinguisher),
            title: const Text('Create Your Tips'),
            onTap: () => context.pushNamed('CreateMaps'),
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
