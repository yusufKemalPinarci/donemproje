import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String currentUser;
  final String otherUser;

  const ChatPage({Key? key, required this.currentUser, required this.otherUser}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final _messagesRef;
  late final TextEditingController _textController;

  var Message;

  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseFirestore.instance
        .collection('users')
        .doc("messages")
        .snapshots();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser),
      ),
      body: Column(
          children: [
      Expanded(
      child: StreamBuilder(
      stream: _messagesRef.child("${widget.currentUser}_${widget.otherUser}").onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data! != null) {
          Map<dynamic, dynamic>? messages = snapshot.data as Map?;
          var messageList = [];

          messages?.forEach((key, value) {
            var message = Message.fromMap(value);
            messageList.add(message);
          });

          return ListView.builder(
            itemCount: messageList.length,
            itemBuilder: (context, index) {
              var message = messageList[index];
              return ListTile(
                title: Text(message.sender),
                subtitle: Text(message.text),
              );
            },
          );
        } else {
          return Center(
            child: Text("Henüz mesaj yok"),
          );
        }
      },
    ),
    ),
    Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
    children: [
    Expanded(
    child: TextField(
    controller: _textController,
    decoration: InputDecoration(
    hintText: "Mesajınızı buraya yazın",
    ),
    ),
    ),
      IconButton(
        icon: Icon(Icons.send),
        onPressed: _sendMessage,
      ),
    ],
    ),
    ),
          ],
      ),
    );
  }

  void _sendMessage() {
    String text = _textController.text.trim();
    if (text.isNotEmpty) {
      _textController.clear();
      final message = ChatMessage(
        text: text,
        userId: _userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      _messagesRef.push().set(message.toJson());
    }
  }
}

class ChatMessage {
  final String text;
  final String userId;
  final int timestamp;

  ChatMessage({
    required this.text,
    required this.userId,
    required this.timestamp,
  });

  ChatMessage.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        userId = json['userId'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() => {
    'text': text,
    'userId': userId,
    'timestamp': timestamp,
  };
}

