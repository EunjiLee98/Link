import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:link_ver1/services/database_service.dart';
import 'package:link_ver1/widgets/message_tile.dart';

//주석
class ChatPage extends StatefulWidget {
  final String groupId;
  final String userName;
  final String groupName;


  ChatPage({this.groupId, this.userName, this.groupName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot> _chats;
  DocumentSnapshot _groupInfo;
  TextEditingController messageEditingController = new TextEditingController();
  ScrollController scrollController = new ScrollController();
  Widget _chatMessages() {

    return StreamBuilder(
      stream: _chats,
      builder: (context, snapshot) {
        Timer(
            Duration(milliseconds: 100),
                () => scrollController
                .jumpTo(scrollController.position.maxScrollExtent));
        return snapshot.hasData
            ? ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.only(bottom: 80),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].data()["message"],
                    sender: snapshot.data.documents[index].data()["sender"],
                    sentByMe: widget.userName ==
                        snapshot.data.documents[index].data()["sender"],
                    now: snapshot.data.documents[index].data()["time"],
                  );
                }
                ,
                )
            : Container();
      },

    );
  }

  // Widget _groupUsers(){
  //
  //
  //       return ListView.builder(
  //         padding: EdgeInsets.only(bottom: 80),
  //         itemCount: _groupInfo.
  //         itemBuilder: (context,index){
  //           return ListTile(
  //             title: Text(snapshot.data['members']),
  //           );
  //         },
  //       ) :
  //           Text('Nothing');
  //     },



  _sendMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text,
        "sender": widget.userName,
        'time': DateTime.now(),
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }

    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
    DatabaseService().getChats(widget.groupId).then((val) {
      // print(val);
      setState(() {
        _chats = val;
      });
    });
    DatabaseService().getGroup(widget.groupId).then((val) {
      setState(() {
        _groupInfo = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Color basic = Color.fromARGB(250, 247, 162, 144);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: basic,
        elevation: 0.0,
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            ListTile(
              title: Text('User1'),
            ),
            ListTile(
              title: Text('User2'),
            ),
            ListTile(
              title: Text('User3'),
            ),
            RaisedButton(
                onPressed: (){

                },
                child: Text('나가기'),
            )
          ],
        ),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
          _chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: basic),
                  color: Colors.white,
                ),
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                // color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageEditingController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintText: "Send a message ...",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    GestureDetector(
                      onTap: () {
                        _sendMessage();
                        Timer(
                            Duration(milliseconds: 100),
                                () => scrollController
                                .jumpTo(scrollController.position.maxScrollExtent));
                      },
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            color: basic,
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                            child: Icon(Icons.send, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
