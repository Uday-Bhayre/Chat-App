import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class chatMessage extends StatelessWidget {
  chatMessage({super.key});
  @override
  Widget build(BuildContext context) {
    final currUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('NO messages found'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something Went Wrong'),
          );
        }
        final loadedData = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 15,
            right: 13,
          ),
          reverse: true,
          itemCount: loadedData.length,
          itemBuilder: (context, index) {
            final currMessage = loadedData[index].data();
            final nextMessage = index + 1 < loadedData.length
                ? loadedData[index + 1].data()
                : null;
            final currMessageUserId = currMessage['user-id'];
            final NextMessageUserId =
                nextMessage != null ? nextMessage['user-id'] : null;
            if (currMessageUserId == NextMessageUserId) {
              return MessageBubble.next(
                message: currMessage['messageText'],
                isMe: currUser.uid == currMessageUserId,
              );
            } else {
              // print(currMessage['img-url']);
              return MessageBubble.first(
                  userImage: currMessage['user-image'],
                  username: currMessage['user-name'],
                  message: currMessage['messageText'],
                  isMe: currMessageUserId == currUser.uid);
            }
          },
        );
      },
    );
  }
}
