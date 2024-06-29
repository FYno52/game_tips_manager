import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  _TermsOfServiceScreenState createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  String termsOfServiceContent = '';

  @override
  void initState() {
    super.initState();
    loadTermsOfService();
  }

  Future<void> loadTermsOfService() async {
    final String content =
        await rootBundle.loadString('assets/terms_of_service.md');
    setState(() {
      termsOfServiceContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 125, 255),
        title: const Text('TermsOfService'),
      ),
      body: Markdown(
        data: termsOfServiceContent,
      ),
    );
  }
}
