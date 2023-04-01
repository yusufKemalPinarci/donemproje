import 'package:donemproje/girispage.dart';
import 'package:donemproje/olusturscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'kayitscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(
    isDarkTheme: true,
  ));
}

class MyApp extends StatefulWidget {
  final bool isDarkTheme;

  const MyApp({Key? key, required this.isDarkTheme}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        widget.isDarkTheme ? ThemeData.dark() : ThemeData.light();
    return MaterialApp(debugShowCheckedModeBanner: false, home: GirisPage());
  }
}
