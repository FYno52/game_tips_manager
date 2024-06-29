import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String privacyPolicyContent = '';

  @override
  void initState() {
    super.initState();
    loadPrivacyPolicy();
  }

  Future<void> loadPrivacyPolicy() async {
    final String content =
        await rootBundle.loadString('assets/privacy_policy.md');
    setState(() {
      privacyPolicyContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 125, 255),
        title: const Text('PrivacyPolicy'),
      ),
      body: Markdown(
        data: privacyPolicyContent,
      ),
    );
  }
}
