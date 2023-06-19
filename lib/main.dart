import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import 'package:firebase_messaging/firebase_messaging.dart';

import 'helpers/notification_services.dart';
import 'home_screen.dart';

Future<void>firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp();

  NotificationServices notificationServices = NotificationServices();
  notificationServices.showNotification(message);
  if (kDebugMode) {
    print(message.notification?.title.toString());
    print(message.notification?.body.toString());
    print(message.data.toString());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}