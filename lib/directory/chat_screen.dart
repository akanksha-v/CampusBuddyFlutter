import 'dart:async';

import 'dart:io';
import 'package:campusbuddy/auth/user.dart';
import 'package:firebase_database/firebase_database.dart';

import '../main.dart';
import 'package:flutter/material.dart';
import 'directory.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/ChatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  //List<QueryDocumentSnapshot> listMessage = new List.from([]);

  void onSendMessage(String content) async {
    if (content.trim() != '') {
      textEditingController.clear();
      final user = auth.currentUser.email;

      CollectionReference messages =
          FirebaseFirestore.instance.collection('messages');

      await messages
          .add({'content': content, 'by': user, 'time': DateTime.now()});
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[700],
        title: Text("Chat"),
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('time', descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Center(
                      heightFactor: 10,
                      widthFactor: 10,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ),
                    );

                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.indigo[600]),
                      ),
                    );

                  default:
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    else
                      return ListView.builder(
                        reverse: true,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = snapshot.data.docs[index];
                            return ListTile(
                              title: Text(
                                doc["by"],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.grey[400]),
                              ),
                              subtitle: Text(doc["content"],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo[500],
                                      fontSize: 18.0)),

                              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                            );
                          });
                }
              }),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                          hintText: "Type your message here..",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      onSendMessage(textEditingController.text);
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.indigo[700],
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
