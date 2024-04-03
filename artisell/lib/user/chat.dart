import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//corect code
// Assuming you have chatpage.dart for navigation

class chat extends StatefulWidget {
  const chat({Key? key}) : super(key: key);

  @override
  State<chat> createState() => _ChatState();
}

class _ChatState extends State<chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xffd2cdbf),
      appBar: AppBar(leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back,color: Colors.white,),
      ),backgroundColor: Color(0xff413821),
        title: const Text("Chat",style: TextStyle(color: Colors.white),),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('email',isEqualTo: 'admin@gmail.com').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (_auth.currentUser!.email != data["email"]) {
      return ListTile(
        title: Text(data['email'],style: TextStyle(fontSize: 20),),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverUserEmail: data['email'],
                receiverUserID: data['uid'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatScreen({
    required this.receiverUserEmail,
    required this.receiverUserID,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserID,
        _messageController.text,
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor:Color(0xffd2cdbf),
      appBar: AppBar(leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back,color: Colors.white,),
      ),backgroundColor:Color(0xff413821),
        title: Text(widget.receiverUserEmail,style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
        widget.receiverUserID,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration:  InputDecoration(contentPadding: EdgeInsets.all(10),
              hintText: "Enter a message",
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send,color: Colors.black,),
          onPressed: sendMessage,
        ),
      ],
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    bool isMe = data['senderId'] == _firebaseAuth.currentUser!.uid;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isMe ? Color(0xFFDCF8C6) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['senderEmail'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isMe ? Color(0xff413821) : Color(0xff986144),
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                data['message'],
                style: TextStyle(
                  fontSize: 16.0,
                  color: isMe ? Color(0xff413821) : Color(0xff986144),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String? currentUserEmail = _firebaseAuth.currentUser!.email;
    final Timestamp timestamp = Timestamp.now();
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail!,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
    );
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final Timestamp timestamp;
  final String message;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.timestamp,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}