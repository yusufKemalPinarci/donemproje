import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donemproje/olusturscreen.dart';
import 'package:donemproje/profilscreen.dart';
import 'package:flutter/material.dart';

class ListelePage extends StatefulWidget {
  const ListelePage({Key? key}) : super(key: key);

  @override
  State<ListelePage> createState() => _ListelePageState();
}

final firestoreInstance = FirebaseFirestore.instance;

class _ListelePageState extends State<ListelePage> {
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder(
        stream: _stream,
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var user = snapshot.data!.docs[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilPage(userId: user.id),
                          ),
                        );
                      },
                      child: Card(
                        child: Container(
                          height: size.height * .2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                            Border.all(color: Colors.green, width: 2),
                            borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: CircleAvatar(
                                    minRadius: 40,
                                    backgroundColor: Colors.green,
                                    backgroundImage: user["resimUrl"]!=null?NetworkImage(user['resimUrl'])
                                        : null,
                                    child: user['resimUrl'] == null
                                        ? Icon(Icons.person, size: 40)
                                        : null,
                                  ),
                                ),
                                Text(
                                  user['name'],
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
                child: Text("Henüz kullanıcı yok."),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),

      floatingActionButton: FloatingActionButton(onPressed: (){

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OlusturPage(),
          ),
        );
      },child: Icon(Icons.add),backgroundColor: Colors.green),
    );
  }
}
