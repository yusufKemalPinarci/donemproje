import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'girispage.dart';
class KendiProfilPage extends StatefulWidget {
  const KendiProfilPage({Key? key}) : super(key: key);

  @override
  State<KendiProfilPage> createState() => _KendiProfilPageState();
}

class _KendiProfilPageState extends State<KendiProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [ElevatedButton(onPressed: () async {
      await FirebaseAuth.instance.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GirisPage(),
        ),
      );
    }, child: Text("Çıkış Yap"))]),);
  }
}
