import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:solution/screens/home.dart';

import 'config/strings.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_TITLE,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Home(),
    );
  }
}
