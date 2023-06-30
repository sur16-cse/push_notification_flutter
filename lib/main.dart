import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'helpers/notification_services.dart';
import 'home_screen.dart';
import 'message_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationServices.backgroundMessage();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  HomeScreen( navigatorKey: navigatorKey,),
        routes: <String, WidgetBuilder>{
          '/message': (BuildContext context) => const MyWidget(),
        }
    );
  }
}