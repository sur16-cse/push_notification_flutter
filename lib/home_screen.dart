import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:push_notification_firebase/message_screen.dart';

import 'helpers/notification_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermissions();
    notificationServices.getData('ic_stat_notifications_active', "Test_push_notification", "Test push notification", "package push_notification_firebase");
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print("device token");
        print(value);
      }
    });
    notificationServices.sendRegistrationToken();
    notificationServices.updateStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Flutter Notification"), backgroundColor: Colors.blue),
      body: Center(
        child: TextButton( onPressed: (){
          notificationServices.sendPushNotification();
        }, child: const Text('Send Notification'),),
      ),
    );
  }
}