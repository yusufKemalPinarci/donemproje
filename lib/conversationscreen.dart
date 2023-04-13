import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donemproje/olusturscreen.dart';
import 'package:flutter/material.dart';

class ConversationPage extends StatefulWidget {
  final String userId;
  final String conversationId;

  const ConversationPage(
      {Key? key, required this.userId, required this.conversationId})
      : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

TextEditingController mesajController = TextEditingController();

var conversationQuerySnapshot;

Future<void> mesajGonder(
    String currentUserId, String receiverId, String message) async {
  // Check if a conversation document already exists with the two users
  conversationQuerySnapshot = await FirebaseFirestore.instance
      .collection('conversation')
      .where('members', arrayContains: [currentUserId, receiverId]).get();

  if (conversationQuerySnapshot.docs.length > 0) {
    await conversationQuerySnapshot.reference.collection('messages').add({
      'senderId': currentUserId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
    mesajController.clear();
  } else {
    print("buraya girmedi");
    // If no conversation document exists, create a new one and add the message to its sub-collection
    var newConversationDocRef =
        await FirebaseFirestore.instance.collection('conversation').add({
      'members': [currentUserId, receiverId],
    });
    await newConversationDocRef.collection('messages').add({
      'senderId': currentUserId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
    mesajController.clear();
  }
}

class _ConversationPageState extends State<ConversationPage> {
  late CollectionReference _ref;

  @override
  void initState() {
    _ref = FirebaseFirestore.instance.collection('conversation');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [CircleAvatar(), SizedBox(width: 8), Text('kullanıcı adı')],
        ),
        actions: [
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: Icon(Icons.info), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _ref
                .where('members',
                    arrayContains: [widget.userId, widget.conversationId])
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Bir hata oluştu: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return Expanded(
                child: Container(color: Colors.green,
                  child: ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final DocumentSnapshot document =
                          snapshot.data!.docs[index];
                      final bool isMyMessage =
                          document['messages/senderId'] == widget.userId;
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isMyMessage ? Colors.blue : Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment:
                            isMyMessage ? Alignment.topRight : Alignment.topLeft,
                        child: GestureDetector(
                          onLongPress: () {
                            // Handle long press event
                          },
                          child: Text(
                            document['message'],
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.blue,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: mesajController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Mesaj yazın',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    mesajGonder(widget.userId, widget.conversationId,
                        mesajController.text);
                  },
                  icon: Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
