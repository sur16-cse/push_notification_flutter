import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:push_notification/helpers/notification_services.dart';
import 'package:http/http.dart' as http;

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
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      print("device token");
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Flutter Notification"), backgroundColor: Colors.blue),
      body: Center(
        child: TextButton( onPressed: (){
          notificationServices.getDeviceToken().then((value) async{
            var data={
              'to':value.toString(),
              'priority':'high',
              'notification':{
                'title':'Surbhi',
                'body':'Subscribe to my channel',

              },
              // 'data':
            };
            await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),body: jsonEncode(data),headers: {
              'Content-Type':'application/json,charset=UTF-8',
              'Authorization':'key=AAAAuWPoqUE:APA91bFysWspzQHc67yU-G0AR3ehcdef8iaBxQK0gA8hPiBvSAcEqD2GDHjP5HXVwuCJ4CWMHMjRsRzdYbH_X8FId8rntHr3xwBdqFkUkisO5L-bDNrAivJKOyro6Z_7BduIb63MZrYl'
            });
          });
        }, child: Text('Send Notification'),),
      ),
    );
  }
}