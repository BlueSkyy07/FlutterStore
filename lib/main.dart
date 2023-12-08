import 'dart:io';

import 'package:admin/pages/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: FirebaseOptions(
              apiKey: "AIzaSyCgkd6mmDjA7LeDLG0qO9A3sPlS8UXEk1A",
              appId: "1:297793596859:android:3c30ae24c542907d79a89e",
              messagingSenderId: "297793596859",
              projectId: "cuahang-dd5e0"),
        )
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
