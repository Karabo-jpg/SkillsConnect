import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Not logged in'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('participants', arrayContains: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }
          // Group messages by chat partner
          final messages = snapshot.data!.docs;
          final Map<String, Map<String, dynamic>> latestMessages = {};
          for (var doc in messages) {
            final data = doc.data() as Map<String, dynamic>;
            final participants = List<String>.from(data['participants'] ?? []);
            final otherUserId = participants.firstWhere((id) => id != currentUser.uid, orElse: () => '');
            if (otherUserId.isEmpty) continue;
            if (!latestMessages.containsKey(otherUserId) ||
                (data['timestamp'] as Timestamp).toDate().isAfter((latestMessages[otherUserId]!['timestamp'] as Timestamp).toDate())) {
              latestMessages[otherUserId] = {...data, 'id': doc.id};
            }
          }
          if (latestMessages.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }
          return ListView(
            children: latestMessages.entries.map((entry) {
              final otherUserId = entry.key;
              final msg = entry.value;
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('Chat with $otherUserId'),
                subtitle: Text(msg['text'] ?? ''),
                trailing: Text(
                  (msg['timestamp'] as Timestamp).toDate().toLocal().toString().substring(0, 16),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: null, // Chat feature removed, tap disabled
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
// FILE DELETED: Chat feature removed.
