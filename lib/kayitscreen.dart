import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donemproje/listelescreen.dart';
import 'package:donemproje/listeleturist.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'girispage.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class KayitScreen extends StatefulWidget {
  const KayitScreen({Key? key}) : super(key: key);

  @override
  State<KayitScreen> createState() => _KayitScreenState();
}

User? user = FirebaseAuth.instance.currentUser;

class _KayitScreenState extends State<KayitScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _password;
  late String _email;
  late String _isim;

  late String _tur;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        var database =
            FirebaseFirestore.instance.collection("users").doc(_email);
        database.set({
          'name': _isim,
          'email': _email,
          'tür': _tur,
          'resimUrl': null,
          'yaş': 18,
          'hakkinda': null
        });
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GirisPage(),
          ),
        );

        // Kullanıcı başarılı bir şekilde kaydedildi
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('Güçsüz parola.');
        } else if (e.code == 'email-already-in-use') {
          print('Bu e-posta zaten kullanılıyor.');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // E-posta doğrulama e-postasını gönderin
      await userCredential.user!.sendEmailVerification();
    } catch (e) {
      print('E-posta doğrulama hatası: $e');
    }
  }

  bool _isChecked = true;
  bool _button1Selected = false;
  bool _button2Selected = false;

  void _selectButton1() {
    setState(() {
      _tur = "rehber";
      _button1Selected = true;
      _button2Selected = false;
    });
  }

  void _selectButton2() {
    setState(() {
      _tur = "turist";
      _button1Selected = false;
      _button2Selected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {},
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
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => GirisPage()));
                },
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
          child: ListView(children: [
            Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Kayıt ol",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("Bu uygulama çok güzel"),
                    ),
                    TextFormField(
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            label: Text("isim")),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Lütfen bir isim girin.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _isim = value!;
                        }),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              label: Text("email")),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Lütfen bir email girin.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value!;
                            if (!_email.contains('@')) {
                              _email += '@gmail.com';
                            }
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextFormField(
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              label: Text("sifre")),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Lütfen bir sifre girin.';
                            } else if (value.length < 6) {
                              return 'Parola en az 6 karakter olmalıdır.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _password = value!;
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _selectButton1,
                          style: ElevatedButton.styleFrom(
                            primary:
                                _button1Selected ? Colors.green : Colors.grey,
                          ),
                          child: Text('rehber'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ElevatedButton(
                            onPressed: _selectButton2,
                            style: ElevatedButton.styleFrom(
                              primary:
                                  _button2Selected ? Colors.green : Colors.grey,
                            ),
                            child: Text('turist'),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: _register,
                        child: Text("Kayıt Ol"))
                  ]),
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GirisPage(),
                    ),
                  );
                },
                child: Text(
                  "zaten hesabım var",
                  style: TextStyle(fontSize: 18),
                ))
          ]),
        ),
      ),
    );
  }
}
