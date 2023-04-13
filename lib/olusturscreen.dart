import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'listelescreen.dart';

class OlusturPage extends StatefulWidget {
  const OlusturPage({Key? key}) : super(key: key);

  @override
  State<OlusturPage> createState() => _OlusturPageState();
}

TextEditingController _hakkindaController = TextEditingController();
int _selectedAge = 18;

var db = FirebaseFirestore.instance;

User? user = FirebaseAuth.instance.currentUser;
String? email = user?.email;
String? userId = user?.uid;
File? _imageFile;

late String eskiHakkinda;
late String eskiYas;
late String eskiIsim;


class _OlusturPageState extends State<OlusturPage> {
  String name = "belirsiz";

  late DocumentReference userDocRef;

  String? photoUrl;

  TextEditingController _isimController = TextEditingController();



  @override
  void initState() {
    db.collection("users").where("email", isEqualTo: email).get().then(
      (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          setState(() {
            name = docSnapshot['name'];
            photoUrl = docSnapshot['resimUrl'] as String?;
            eskiIsim=name;
            eskiYas=docSnapshot['yaş'];
            eskiHakkinda=docSnapshot['hakkinda'];
          });
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    userDocRef = FirebaseFirestore.instance.collection('users').doc(email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _showDialog(Widget child) {
      showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => Container(
                height: 216,
                padding: const EdgeInsets.only(top: 6.0),
                // The Bottom margin is provided to align the popup above the system navigation bar.
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                // Provide a background color for the popup.
                color: CupertinoColors.systemBackground.resolveFrom(context),
                // Use a SafeArea widget to avoid system overlaps.
                child: SafeArea(
                  top: false,
                  child: child,
                ),
              ));
    }

// Resim seçme işlemi
    final picker = ImagePicker();

// Resmi yükleme işlemi
    Future uploadImage(String userId) async {
      Map<String, dynamic> data = {};

      if (_imageFile == null) {
        print('Resim seçilmedi.');
      }

      if (_imageFile != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('users/$userId');
        final uploadTask = storageRef.putFile(_imageFile!);
        await uploadTask.whenComplete(() => null);

        final downloadUrl = await storageRef.getDownloadURL();
        print('Resim yüklendi. Download URL: $downloadUrl');
        data['resimUrl'] = downloadUrl;
      }

      String yeniHakkinda = _hakkindaController.text;
      if (yeniHakkinda.isEmpty) {
        yeniHakkinda = eskiHakkinda; // Eski bilgiyi kullan
      }

      String yeniYas = '$_selectedAge';
      if (yeniYas.isEmpty) {
        yeniYas = eskiYas; // Eski bilgiyi kullan
      }

      String yeniIsim = _isimController.text;
      if (yeniIsim.isEmpty) {
        yeniIsim = eskiIsim; // Eski bilgiyi kullan
      }

      data['hakkinda'] = yeniHakkinda;
      data['yaş'] = yeniYas;
      data['name'] = yeniIsim;

      if (data.isNotEmpty) {
        userDocRef.update(data);
      }
    }

    Future<void> _pickImage(ImageSource source) async {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }

    Future<void> _showPickImageDialog() async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Resim Yükleme"),
            content: Text("Kameradan mı yoksa galeriden mi seçmek istersiniz?"),
            actions: <Widget>[
              TextButton(
                child: Text("Kamera"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              TextButton(
                child: Text("Galeri"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          );
        },
      );
    }
    return Scaffold(
      body: ListView(children: [
        Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      _showPickImageDialog();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.camera_alt),
                      backgroundColor: Colors.green,
                      minRadius: 40,
                      backgroundImage: _imageFile != null
                          ? Image.file(_imageFile!).image
                          : photoUrl != null
                              ? NetworkImage(photoUrl!)
                              : null,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Yaşınız:   ${_selectedAge} ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        // Display a CupertinoPicker with list of fruits.
                        onPressed: () => _showDialog(CupertinoPicker(
                          scrollController:
                              FixedExtentScrollController(initialItem: 17),
                          itemExtent: 60.0,
                          onSelectedItemChanged: (int value) {
                            setState(() {
                              _selectedAge = value + 1;
                            });
                          },
                          children: List<Widget>.generate(100, (int index) {
                            return Center(
                              child: Text('${index + 1}'),
                            );
                          }),
                        )),
                        // This displays the selected fruit name.
                        child: Text(
                          "seç",
                          style: const TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(children: [
                    Text(
                      "isminiz:",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _isimController,
                        decoration: InputDecoration(
                          hintText: '${name}',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: TextFormField(
                      controller: _hakkindaController,
                      maxLines: 3, // birden fazla satır için
                      decoration: InputDecoration(
                        hintText: 'Kendinizi Tanıtın...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        uploadImage(email!);

                        _imageFile = null;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListelePage()));
                      },
                      child: Center(
                        child: Text(
                          "PROFİLİNİ OLUŞTUR",
                          style: TextStyle(color: Colors.black),
                        ),
                      )),
                ],
              ),
            ))
      ]),
    );
  }
}
