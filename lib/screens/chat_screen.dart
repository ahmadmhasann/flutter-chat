import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/widgets/message_bubble.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/widgets.dart';
import 'package:flash_chat/widgets/alert.dart';
class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = ScrollController();
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  final messageTextController = TextEditingController();
  String messageText;
  FirebaseUser loggedInUser;
  Stream<QuerySnapshot> chatStream;
  Stream<QuerySnapshot> userStream;
  String lastSender;
  bool repeated = false;



  @override
  void initState() {
    super.initState();
    getCurrentUser();
    chatStream = _firestore.collection('messages').orderBy('timestamp', descending: true).snapshots();
    userStream = _firestore.collection('users').snapshots();

  }

  void getMessages() async {
    final messages = await _firestore.collection('messages').getDocuments();
    for (var message in messages.documents) {
      print(message.data);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
  }

  String getUserName(dynamic users, String email) {
    for (final user in users) {
      if (user['email'] == email) {
        return user['name'];
      }
    }
    return 'unknown';
  }

  String getUserImage(dynamic users, String email) {
    for (final user in users) {
      if (user['email'] == email) {
        return user['image'];
      }
    }
    return 'https://www.binaryhermit.com/wp-content/uploads/2015/05/null-value.jpg';
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {

    Stream<List<QuerySnapshot>> combinedStream = Rx.combineLatest2(
        chatStream, userStream, (messages, users) => [messages, users]);

    return Scaffold(
      backgroundColor: Color(0xFF0C0C0D),

      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('Chat'),
        backgroundColor: Color(0xFF00695c),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            StreamBuilder(
              stream: combinedStream,
              builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshots) {
                if (!snapshots.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                else {
                  final chats = snapshots.data[0].documents.reversed;
                  final users = snapshots.data[1].documents.reversed;
                  List<MessageBubble> messageWidgets = [];
                  for (var message in chats) {
                    final messageText = message.data['text'];
                    final messageSender = message.data['sender'];
                    final image = getUserImage(users, messageSender);
                    if (lastSender == null) {
                      lastSender = messageSender.toString();
                      repeated = false;
                    }
                    else if (lastSender == messageSender.toString()) {
                      repeated = true;
                    }
                    else {
                      repeated = false;
                      lastSender = messageSender.toString();
                    }

                    messageWidgets.add(MessageBubble(
                      text: messageText,
                      image: image,
                      sender: getUserName(users, messageSender),
                      repeated: repeated,
                      isMe: (messageSender == loggedInUser.email),
                    ));
                  }
                  lastSender = null;
                  messageWidgets = new List.from(messageWidgets.reversed);
                  return Expanded(
                    child: ListView(
                      controller: _controller,
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                      children: messageWidgets,
                    ),
                  );
                }

              },
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF00695c), width: 2.0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(color: Colors.white),
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        hintText: 'Type your message here...',
                        hintStyle: TextStyle(
                          color: Colors.grey
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        messageTextController.clear();
                      });
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'timestamp' : DateTime.now().millisecondsSinceEpoch,
                      });
                      _controller.jumpTo(_controller.position.minScrollExtent);

                    },
                    child: Icon(Icons.send, size: 35, color: Color(0xFF00695c),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
