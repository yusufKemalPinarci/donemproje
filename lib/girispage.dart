import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donemproje/kayitscreen.dart';
import 'package:donemproje/listelescreen.dart';
import 'package:donemproje/listeleturist.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'girispage.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class GirisPage extends StatefulWidget {
  const GirisPage({Key? key}) : super(key: key);

  @override
  State<GirisPage> createState() => _GirisPageState();
}

class _GirisPageState extends State<GirisPage> {
  final _formKey = GlobalKey<FormState>();

  late String _password;
  late String _email;
  late String _isim;
  late String _tur;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        if (userCredential.user != null) {
          // Kullanıcı doğrulandı, kullanıcının türüne göre ilgili sayfaya yönlendirme yapılabilir
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.email).get();
          _tur = userDoc['tür'];

          if (_tur == 'turist') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListeleTuristPage()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListelePage()));
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(
           msg: "gmail veya şifre yanlış"
          );

          print('Kullanıcı bulunamadı.');
        } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(
              msg: "gmail veya şifre yanlış"
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
        ElevatedButton(
        style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
    ),
    onPressed: () {
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => KayitScreen()),
    );
    },
    child: Center(
    child: Text(
    "kayıt ol",
    style: TextStyle(color: Colors.black),
    ),
    )),
    Padding(
    padding: const EdgeInsets.only(right: 10),
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    ),
    onPressed: () {},
    child: Center(
    child: Text(
    "giriş yap",
    style: TextStyle(color: Colors.black),
    ),
    )),
    ),
    ],
    ),
    body: Center(
    child: Container(
    padding: EdgeInsets.all(20),
    child: ListView(children: [Form(
    key: _formKey,
    child:
    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(
    "Giriş Yap",
    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
    Padding(
    padding: const EdgeInsets.all(20.0),
    child: Text("Bu uygulama çok güzel"),
    ),
    Padding(
    padding: const
    EdgeInsets.all(10.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: "Email",
          hintText: "Email giriniz",
          border: OutlineInputBorder(
              borderRadius:
              BorderRadius.all(Radius.circular(20))),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email giriniz';
          }
          return null;
        },
        onSaved: (value) {
          _email = value!;
        },
      ),
    ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Şifre",
            hintText: "Şifre giriniz",
            border: OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(20))),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Şifre giriniz';
            }
            return null;
          },
          onSaved: (value) {
            _password = value!;
          },
        ),
      ),
      ElevatedButton(
        onPressed: _login,

        child: Text("Giriş"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
      ),
    ]),
    ),
    ]),
    ),
    ),
    );
  }
}