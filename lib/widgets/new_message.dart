import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class newMessage extends StatefulWidget {
  newMessage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _newMessageState();
  }
}

class _newMessageState extends State<newMessage> {
  var _messageController = TextEditingController();

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _messageController.clear();

   final currUser= FirebaseAuth.instance.currentUser!;
   final userData= await FirebaseFirestore.instance.collection('users').doc(currUser.uid).get();

    FirebaseFirestore.instance.collection('chat').add({
      'messageText': enteredMessage,
      'createdAt': Timestamp.now(),
      'user-id': currUser.uid,
      'user-name': userData.data()!['user-name'],
      'user-image': userData.data()!['img-url'],
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enableSuggestions: true,
              autocorrect: true,
              decoration:
                  const InputDecoration(labelText: 'Enter a message...'),
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: _submitMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
