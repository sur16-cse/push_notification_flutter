import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../message_screen.dart';

//notification handle in background
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

//handling backgroundMessage call
void ext(){
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}


class NotificationServices {
  late String icon;
  late String title;
  late String message;
  late String body;
  late String deepLink;

  //instantiating a firebase
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  //instantiate a local notification
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  //initialising local notification
  Future<void> initLocalNotification(BuildContext context,
      RemoteMessage message) async {
    //helps to change the notification status icon
    var androidInitializationSettings = const AndroidInitializationSettings(
        '@mipmap/ic_launcher'
    );
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
          // handle interaction when app is active for android
          handleMessage(context, message);
        });
  }

//handle incoming message when app is in foreground
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
            'Receive message title: ${message.notification
                ?.title} \n Received message body: ${message.notification
                ?.body}');
        print(message.data.toString());
        print(message.data["type"]);
        print(message.data["id"]);
      }
      initLocalNotification(context, message);
      showNotification(message);
      // Handle the received message
    });
  }

  //handle incoming message when app is in background
  static void backgroundMessage() {
    ext();
  }

  Future<void> showNotification(RemoteMessage message) async {
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

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification?.title.toString(),
          message.notification?.body.toString(),
          notificationDetails);
    });
  }

  void isTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print("refresh");
      }
    });
  }

  Future<String?> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }
    return token;
  }

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

  //handle deep linking when app terminated or in background
  Future<void> setupInteractMessage(BuildContext context) async {
    //when app is terminated
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && context.mounted) {
      handleMessage(context, initialMessage);
    }

    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

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

  void getData(String? icon, String? title, String? message, String body) {
    icon = icon;
    title = title;
    message = message;
    body = body;
  }


  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  }

  Future<void> sendRegistrationToken() async {
    final url = Uri.parse('http://172.17.160.1:3000/register');
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