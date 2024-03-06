import 'dart:async';
import 'dart:convert';

import 'package:chatapp/chat_widget.dart';
import 'package:chatapp/event.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String roomID;
  final String username;

  const ChatPage({super.key, required this.roomID, required this.username});

  @override
  ConsumerState createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _userInputController = TextEditingController();
  late WebSocketChannel _webSocketChannel;
  final StreamController<List<ChatEvent>> _streamController =
      StreamController<List<ChatEvent>>();

  final ScrollController _listViewController = ScrollController();

  List<ChatEvent> chatEvents = [];

  @override
  void initState() {
    super.initState();
    _webSocketChannel = WebSocketChannel.connect(
        Uri.parse('ws://chatserver-xhbsi6bjoa-ew.a.run.app/ws?roomID=${widget.roomID}'));
  }

  @override
  void dispose() {
    _userInputController.dispose();
    _streamController.close();
    _listViewController.dispose();
    _webSocketChannel.sink.close();
    super.dispose();
  }

  Stream<List<ChatEvent>> get chatEventsListStream => _streamController.stream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: FutureBuilder(
          future: _webSocketChannel.ready,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              _voidStartListening();
              return Column(
                children: [
                  Expanded(
                      child: StreamBuilder(
                          stream: chatEventsListStream,
                          builder: ((context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                return const Center(child: Text("no messages yet"));
                              } else {
                                return ListView(
                                  controller: _listViewController,
                                  children: snapshot.data!
                                      .map((e) => ChatWidget(
                                          chatEvent: e,
                                          currentUser: widget.username))
                                      .toList(),
                                );
                              }
                            }
                            return const Center(
                              child: Text(
                                  "There was an unexpected error loading messages"),
                            );
                          }))),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _userInputController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '...',
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (_userInputController.text.isNotEmpty) {
                              DateTime now = DateTime.now();
                              Map<String, dynamic> json = {
                                "event_type": "message",
                                "payload": _userInputController.text,
                                "date":
                                    DateFormat('yyyy-MM-dd hh:mm').format(now),
                                "from": widget.username
                              };
                              _webSocketChannel.sink.add(jsonEncode(json));
                              ChatEvent sendEvent = ChatEvent.fromJson(json);
                              chatEvents = [...chatEvents, sendEvent];
                              _streamController.add(chatEvents);
                              if (_listViewController.hasClients) {
                                _listViewController.jumpTo(
                                    _listViewController.position.maxScrollExtent);
                              }
                              _userInputController.clear();
                            }
                          },
                          child: const Icon(Icons.send))
                    ],
                  ),
                ],
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    "Error occured connecting to the server - ${snapshot.error}"),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  _voidStartListening() {
    _streamController.add([]);
    _webSocketChannel.stream.listen((data) {
      ChatEvent receivedEvent = ChatEvent.fromJson(jsonDecode(data));
      chatEvents = [...chatEvents, receivedEvent];
      _streamController.add(chatEvents);
    }, onError: (error) {
      print(error);
    }, onDone: () {
      print("connection closed");
    });
  }
}
