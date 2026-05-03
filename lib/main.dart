import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/login_screen.dart';
// comment if testing on web
// import 'services/api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // comment out if testing on web
    // _setupFCM();
  }

  // Future<void> _setupFCM() async {
  //   if (kIsWeb) return;
  //   final messaging = FirebaseMessaging.instance;
  //   await messaging.requestPermission();

  //   final token = await messaging.getToken();
  //   if (token != null) {
  //     final prefs = await SharedPreferences.getInstance();
  //     if (prefs.getString('token') != null) {
  //       await ApiService.updateFcmToken(token);
  //     }
  //   }

  //   messaging.onTokenRefresh.listen(ApiService.updateFcmToken);

  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     // Foreground: tambahkan snackbar/local notification di sini
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeGuard Migas',
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}