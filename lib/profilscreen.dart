
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donemproje/conversationscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {


  const ProfilPage({Key? key, required this.ReceiverId}) : super(key: key);
  final String ReceiverId;
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}


class _ProfilPageState extends State<ProfilPage> {
  late String _ReceiverId;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _ReceiverId = widget.ReceiverId;
    final User? user = FirebaseAuth.instance.currentUser;
    _userId = user!.uid; // kullanıcının UID'si





  }

  Widget _buildProfil() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_ReceiverId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var user = snapshot.data!;
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: CircleAvatar(
                  minRadius: 60,
                  backgroundImage: user['resimUrl'] != null
                      ? NetworkImage(user['resimUrl'])
                      : null,
                  child: user['resimUrl'] == null
                      ? Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: ListTile(
                    title: Text(user['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Yaş: ${user['yaş']}'),
                      ],
                    ),
                    onTap: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  user['hakkinda'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(fontSize: 25),
                ),
              )
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildProfil(),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.green,onPressed: (){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationPage(userId: _userId, conversationId: _ReceiverId)));


      },child: Icon(Icons.send)),
    );
  }
}
