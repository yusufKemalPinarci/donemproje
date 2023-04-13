import 'dart:async';

import 'package:donemproje/girispage.dart';
import 'package:donemproje/listelescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(
    isDarkTheme: false,
  ));
}

class MyApp extends StatefulWidget {
  final bool isDarkTheme;

  const MyApp({Key? key, required this.isDarkTheme}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<User?>? _authStateChangesSubscription;

 var sayfa;

  @override
  void initState() {
    super.initState();
    _authStateChangesSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        //kullanıcı oturum açmamış
       sayfa=GirisPage();
      } else {
        // Kullanıcı oturum açmış.
        sayfa=ListelePage();
      }
    });
  }

  @override
  void dispose() {
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        widget.isDarkTheme ? ThemeData.dark() : ThemeData.light();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: sayfa
        ),
      ),
    );
  }
}
