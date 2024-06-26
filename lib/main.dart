import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_tips_manager/screens/start_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preferred device orientations
  await SystemChrome.setPreferredOrientations([
    // DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,
  ]);

  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartScreen(),
    ),
  );
}
