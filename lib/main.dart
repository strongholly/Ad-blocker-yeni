import 'package:flutter/material.dart';
import 'services/ad_blocker_service.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdBlockerService().initialize();
  runApp(const AdBlockerBrowserApp());
}

class AdBlockerBrowserApp extends StatelessWidget {
  const AdBlockerBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro Ad Blocker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
