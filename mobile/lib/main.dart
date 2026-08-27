import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'database/db_helper.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.init();
  runApp(const RaktDrishtiApp());
}

class RaktDrishtiApp extends StatelessWidget {
  const RaktDrishtiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RaktDrishti',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
