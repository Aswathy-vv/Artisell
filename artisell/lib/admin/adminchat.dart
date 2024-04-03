import 'package:artisell/user/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreenn extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreenn> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user; // Initialize as late User

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    FirebaseAuth auth = FirebaseAuth.instance;

    auth.authStateChanges().listen((User? user) {
      if (userId == null || user == null || userId != user.uid) {
        // User is not authenticated or user ID doesn't match, navigate to sign-in screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
        // User is authenticated, update user and continue
        setState(() {
          _user = user; // Initialize _user here
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: Color(0xffd2cdbf),
      appBar: AppBar(leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back,color: Colors.white,),
      ),backgroundColor:  Color(0xff413821),
        title: Text('ask questions',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages.reversed) { // Reverse the order of messages
                  final messageText = message['text'];
                  final messageSender = message['sender'];
                  final timestamp = message['timestamp'];

                  if (timestamp is Timestamp) {
                    final timestampDate = timestamp.toDate();
                    final messageWidget = MessageWidget(
                      messageSender,
                      messageText,
                      _user.email == messageSender,
                      timestampDate,
                    );
                    messageWidgets.add(messageWidget);
                  }
                }

                return ListView(
                  reverse: true,
                  children: messageWidgets,
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration.collapsed(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      _firestore.collection('messages').add({
        'text': messageText,
        'sender': _user.email,
        'timestamp': FieldValue.serverTimestamp(),

      });

      _messageController.clear();
    }
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final bool isCurrentUser;

  MessageWidget(this.sender, this.text, this.isCurrentUser, DateTime timestamp);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$sender:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isCurrentUser ? Color(0xff413821) : Color(0xff986144),
              borderRadius: isCurrentUser
                  ? BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              )
                  : BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 16.0,color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
