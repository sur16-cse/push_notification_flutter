import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../message_screen.dart';

// Function to handle background messages received by Firebase Messaging
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage? message) async {
  await Firebase.initializeApp();
  NotificationServices notificationServices = NotificationServices();

  if (message != null) {
    await notificationServices.showNotification(message);
    if (kDebugMode) {
      print("background");
      print(message.notification?.title.toString());
    }
  }
}

// Function to set up the background message handler
void ext() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

class NotificationServices {
  late String icon;
  late String title;
  late String message;
  late String body;
  late String deepLink;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize local notifications
  Future<void> initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    // Configure the initialization settings for Android and iOS
    var androidInitializationSettings = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // Initialize the FlutterLocalNotificationsPlugin with the settings
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (payload) {
        // Handle interaction when the app is active (Android)
        handleMessage(context, message);
      },
    );
  }

  // Handle incoming messages when the app is in the foreground
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
            'Received message title: ${message.notification?.title} \n Received message body: ${message.notification?.body}');
        print(message.data.toString());
        print(message.data["type"]);
        print(message.data["id"]);
      }
      initLocalNotification(context, message);
      showNotification(message);
      // Handle the received message
    });
  }

  // Handle incoming messages when the app is in the background
  static void backgroundMessage() {
    ext();
  }

  // Show a local notification
  Future<void> showNotification(RemoteMessage message) async {
    // Create an Android notification channel
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(1000).toString(),
      'High Importance Notification',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Create the Android notification details
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      icon: 'ic_stat_notifications_active',
      channelDescription: "your channel description",
      importance: Importance.high,
      priority: Priority.high,
      ticker: "ticker",
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    // Delay the notification by zero duration to show immediately
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title.toString(),
        message.notification?.body.toString(),
        notificationDetails,
      );
    });
  }

  // Check if the token needs to be refreshed
  void isTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print("refresh");
      }
    });
  }

  // Get the device token
  Future<String?> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }
    return token;
  }

  // Request notification permissions from the user
  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      // AppSettings.openNotificationSettings();
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }

  // Set up interaction message handling for when the app is terminated or in the background
  Future<void> setupInteractMessage(BuildContext context) async {
    // When the app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && context.mounted) {
      handleMessage(context, initialMessage);
    }

    // When the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  // Handle the received message and navigate to a screen if the message type is 'msj'
  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data["type"] == 'msj') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageScreen(id: message.data['id']),
        ),
      );
    }
  }

  // Set the data for the notification
  void getData(String? icon, String? title, String? message, String body) {
    icon = icon;
    title = title;
    message = message;
    body = body;
  }

  // Subscribe to a topic for push notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }

  // Unsubscribe from a topic for push notifications
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  }

  // Send the registration token to a server for further processing
  Future<void> sendRegistrationToken() async {
    final url = Uri.parse('http://49.249.28.158:3000/register');
    var token = await _firebaseMessaging.getToken();
    var data = '''
    {
      "notification": {
        "body": "this is a body",
        "title": "this is a title"
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      },
      "token": "$token",
      "topics": "test"
    }
  ''';

    final response = await http.post(
      url,
      headers: <String, String>{
        "Content-Type": "application/json",
        "Keep-Alive": "timeout=5",
        "Authorization": "$token"
      },
      body: data,
    );
    print(response.statusCode);
  }

  // Send a push notification to a device or topic
  Future<void> sendPushNotification() async {
    final url = Uri.parse('http://172.17.160.1:3000/push');
    var token = await _firebaseMessaging.getToken();
    var data = '''
    {
      "notification": {
        "body": "this is a body",
        "title": "this is a title"
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      },
      "token": "$token",
      "topics": "test"
    }
  ''';

    final response = await http.post(
      url,
      headers: <String, String>{
        "Content-Type": "application/json",
        "Keep-Alive": "timeout=5",
        "Authorization": "$token"
      },
      body: data,
    );
    print(response.statusCode);
  }
}
