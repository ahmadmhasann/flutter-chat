import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe, this.repeated, this.image});

  final String sender;
  final String text;
  final bool isMe;
  final bool repeated;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          repeated? Container(child: isMe? SizedBox(width: 40,) : Container(), width: 40,) : Container(child: isMe? Container() : Avatar(image: image),),
          SizedBox(width: 5,),
          Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[

              Text(
                repeated? '' : sender,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.white,
                ),
              ),
              repeated? Container() : SizedBox(height: 5,),
              Material(
                borderRadius: isMe
                    ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                    : BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                elevation: 5.0,
                color: isMe ? Color(0xFF00695c) : Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 5,),
          repeated? Container(child: !isMe? SizedBox(width: 40,) : Container(), width: 40,) : Container(child: !isMe? Container() : Avatar(image: image),),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({
    Key key,
    @required this.image,
  }) : super(key: key);

  final String image;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        backgroundImage: NetworkImage(image),
        radius: 19,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
