import 'dart:async';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification/message_screen.dart';

class NotificationServices {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    //helps to change the notification status icon
    var androidInitializationSettings = const AndroidInitializationSettings(
      '@drawable/ic_stat_notifications_active',
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

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
            'Receive message title: ${message.notification?.title} \n Received message body: ${message.notification?.body}');
        print(message.data.toString());
        print(message.data["type"]);
        print(message.data["id"]);
      }
      initLocalNotification(context, message);
      showNotification(message);
      // Handle the received message
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(1000).toString(),
      'High Importance Notification',
      description:
      'This channel is used for important notifications.',
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

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
  await  showNotification(message);
    print("background");
    print(message.notification?.title.toString());
  }

  Future<String?> isTokenRefresh() async {
    _firebaseMessaging.onTokenRefresh.listen((event) {
      event.toString();
      print("refresh");
    });
  }

  Future<String?> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
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
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      // AppSettings.openNotificationSettings();
      print('User declined or has not accepted permission');
    }
  }

  Future<void>setupInteractMessage(BuildContext context) async{
    //when app is terminated
    RemoteMessage? initialMessage=await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage!=null){
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
              builder: (context) => MessageScreen(id: message.data['id']),));
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}