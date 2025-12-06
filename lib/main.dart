import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_todo_app/firebase_options.dart';
import 'package:new_todo_app/presentation/home/dashboard_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'presentation/authentication/login_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await requestNotificationPermission();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }
  final token = await FirebaseMessaging.instance.getToken();
  print("FCM TOKEN: $token");

  runApp(const MyApp());
}

Future<void> requestNotificationPermission() async {
  await Permission.notification.request();
}

Future<void> setupFlutterNotifications() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await setupFlutterNotifications();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser != null
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}
