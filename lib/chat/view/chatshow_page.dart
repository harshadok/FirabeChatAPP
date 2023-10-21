import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.userdata});
  final User? userdata;
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.clear();
    super.dispose();
  }

  sendMessage(String text) async {
    final message = text.trim();
    log("error is =>  before message is here");
    if (message.isNotEmpty) {
      log("error is =>  message is here");
      try {
        await FirebaseFirestore.instance.collection('messages').add({
          'text': message,
          'timestamp': FieldValue.serverTimestamp(),
        }).whenComplete(() {
          log("error is =>  message i s here");
        });
        messageController.clear();
      } catch (e) {
        log("error is =>  from send message");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hey ${widget.userdata?.displayName ?? 'User'}"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = snapshot.data!.docs;
                // log("message are ${messages}");
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message['text']),
                      trailing: Text(message['text']),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    await sendMessage(messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
