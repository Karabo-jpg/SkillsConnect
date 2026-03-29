import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
	final String otherUserId;
	final String otherUserName;
	const ChatPage({Key? key, required this.otherUserId, required this.otherUserName}) : super(key: key);

	@override
	State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
	final TextEditingController _controller = TextEditingController();
	User? get currentUser => FirebaseAuth.instance.currentUser;

	void sendMessage() async {
		final text = _controller.text.trim();
		final user = currentUser;
		if (text.isEmpty || user == null) return;
		await FirebaseFirestore.instance.collection('messages').add({
			'text': text,
			'senderId': user.uid,
			'receiverId': widget.otherUserId,
			'participants': [user.uid, widget.otherUserId],
			'timestamp': FieldValue.serverTimestamp(),
		});
		_controller.clear();
	}

	@override
	Widget build(BuildContext context) {
		final user = currentUser;
		if (user == null) {
			return const Scaffold(body: Center(child: Text('Not logged in')));
		}
		return Scaffold(
			appBar: AppBar(title: Text('Chat with [200~[0m${widget.otherUserName}')),
			body: Column(
				children: [
					Expanded(
						child: StreamBuilder<QuerySnapshot>(
							  stream: FirebaseFirestore.instance
								  .collection('messages')
								  .where('participants', arrayContains: user.uid)
								  .orderBy('timestamp', descending: false)
								  .snapshots(),
							builder: (context, snapshot) {
								if (!snapshot.hasData) {
									return const Center(child: CircularProgressIndicator());
								}
								final docs = snapshot.data!.docs.where((doc) {
									final data = doc.data() as Map<String, dynamic>;
									return (data['participants'] as List).contains(widget.otherUserId);
								}).toList();
								return ListView.builder(
									itemCount: docs.length,
									itemBuilder: (context, index) {
										final data = docs[index].data() as Map<String, dynamic>;
										final isMe = data['senderId'] == user.uid;
										return Align(
											alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
											child: Container(
												margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
												padding: const EdgeInsets.all(10),
												decoration: BoxDecoration(
													color: isMe ? Colors.blue[100] : Colors.grey[200],
													borderRadius: BorderRadius.circular(10),
												),
												child: Text(data['text'] ?? ''),
											),
										);
									},
								);
							},
						),
					),
					Padding(
						padding: const EdgeInsets.all(8.0),
						child: Row(
							children: [
								Expanded(
									child: TextField(
										controller: _controller,
										decoration: const InputDecoration(hintText: 'Type a message...'),
									),
								),
								IconButton(
									icon: const Icon(Icons.send),
									onPressed: sendMessage,
								),
							],
						),
					),
				],
			),
		);
	}
}
