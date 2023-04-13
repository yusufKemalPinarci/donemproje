import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donemproje/chat_page.dart';
import 'package:donemproje/girispage.dart';
import 'package:donemproje/olusturscreen.dart';
import 'package:donemproje/profilscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListelePage extends StatefulWidget {
  const ListelePage({Key? key}) : super(key: key);

  @override
  State<ListelePage> createState() => _ListelePageState();
}

final firestoreInstance = FirebaseFirestore.instance;
final User? user = FirebaseAuth.instance.currentUser;

class _ListelePageState extends State<ListelePage> {
  late Stream<QuerySnapshot> _stream;

  var _kendiId;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(
            child: Icon(Icons.person),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OlusturPage()),
              );
            },
            title: Text("Profil", style: TextStyle(fontSize: 20)),
          ),
          ListTile(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GirisPage()),
              );


            },
            title: Text("Çıkış Yap", style: TextStyle(fontSize: 20)),
          ),
        ]),
      ),
      appBar: AppBar(backgroundColor: Colors.green, actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
              onTap: () {
                if (user != null) {
                  _kendiId = user!.uid; // kullanıcının UID'si
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(),
                  ),
                );
              },
              child: Icon(Icons.message)),
        )
      ]),
      body: StreamBuilder(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var Receiver = snapshot.data!.docs[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfilPage(ReceiverId: Receiver.id),
                          ),
                        );
                      },
                      child: Card(
                        child: Container(
                          height: size.height * .2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: CircleAvatar(
                                    minRadius: 40,
                                    backgroundColor: Colors.green,
                                    backgroundImage:
                                        Receiver["resimUrl"] != null
                                            ? NetworkImage(Receiver['resimUrl'])
                                            : null,
                                    child: Receiver['resimUrl'] == null
                                        ? Icon(Icons.person, size: 40)
                                        : null,
                                  ),
                                ),
                                Text(
                                  Receiver['name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  "Henüz kullanıcı yok.",
                  style: TextStyle(color: Colors.green),
                ),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OlusturPage(),
              ),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.green),
    );
  }
}
