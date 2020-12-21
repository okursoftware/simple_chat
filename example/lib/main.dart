
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/simple_chat.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FutureBuilder(
          // Initialize FlutterFire:
          future: _initialization,
          builder: (context, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return Center(child: Text("Firebase error"),);
            }

            // Once complete, show your application
            if (snapshot.connectionState == ConnectionState.done) {
              return FirstView();
            }

            // Otherwise, show something whilst waiting for initialization to complete
            return Center(child: CircularProgressIndicator(),);
          },
        ),
      )
    );
  }
}


class FirstView extends StatefulWidget {
  @override
  _FirstViewState createState() => _FirstViewState();
}

class _FirstViewState extends State<FirstView> {
  CollectionReference messages = FirebaseFirestore.instance.collection('messages');
  final StreamController<List<ChatMessage>> _messagesController = StreamController<List<ChatMessage>>.broadcast();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<QuerySnapshot> _messagesStream;


  Future<void> addMessage(ChatMessage chatMessage) {


    chatMessage.user.uid = "9c82313b-4163-4a66-984e-56a92af69ba6";
    return messages
        .add(chatMessage.toJson())
        .then((value) => print("Message Added"))
        .catchError((error) => print("Failed to add message: $error"));
  }



  void listenToMessageRealTime(QuerySnapshot snapshot) async {
    await Future.delayed(Duration(milliseconds: 200));
    var messagesItem = List<ChatMessage>();
    var hasDocuments = snapshot.docs.length > 0;
    if (hasDocuments) {
      for (var document in snapshot.docs) {
        //print(document.data);
        messagesItem.add(ChatMessage.fromJson(document.data()));
      }
    }
    _messagesController.add(messagesItem);
    Timer(
        Duration(milliseconds: 300),
            () => _scrollController
            .animateTo(_scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),));


  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _messagesStream = FirebaseFirestore.instance
        .collection("messages")
        .orderBy("createdAt")
        .snapshots()
        .listen(listenToMessageRealTime);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Test"),centerTitle: true,),
      body: StreamBuilder(
            stream: _messagesController.stream,
          builder:  (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              );
            }else{
              return SimpleChat(
                messages: snapshot.data,
                scrollController: _scrollController,
                onSend:addMessage,
                currentUser: ChatUser(uid: "9c82313b-4163-4a66-984e-56a92af69ba6"),
              );
            }
          },),

    );
  }
}
