import 'package:chatapp/event.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  final ChatEvent chatEvent;
  final String currentUser;

  const ChatWidget(
      {super.key, required this.chatEvent, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    bool checkUser = currentUser == chatEvent.from!;
    var color = checkUser ? Colors.green : Colors.blue;
    var alignment = checkUser ? Alignment.centerRight : Alignment.centerLeft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          alignment: alignment,
          child: ClipPath(
            clipper: UpperNipMessageClipperTwo(
                checkUser ? MessageType.send : MessageType.receive),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: color),
              child: Text(
                chatEvent.payload!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        Align(
          alignment: alignment,
          child: Text(
            "${chatEvent.from!} ${chatEvent.date!}",
            style: const TextStyle(fontSize: 8),
          ),
        )
      ],
    );
  }
}
