import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'conversationscreen.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String userId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userId == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Center(child: Text("Bekleyiniz"))],
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("conversation")
                  .where('members', arrayContains: userId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.hasError.toString());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("bekle");
                }

                return ListView(
                  children: snapshot.data!.docs.map((e) {
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConversationPage(
                                    conversationId: e.id, userId: userId)));
                      },
                      child: ListTile(
                        leading: CircleAvatar(),
                        trailing: Column(
                          children: [
                            Text("19.00"),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.blue),
                                child: Center(
                                  child: Text(
                                    "19",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        title: Text("dfdfs"),
                        subtitle: Text("dfsdsffds"),
                      ),
                    );
                  }).toList(),
                );

              }),
    );
  }
}
