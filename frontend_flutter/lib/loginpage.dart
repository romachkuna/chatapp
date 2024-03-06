import 'package:chatapp/chatpage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController roomIDController = TextEditingController();
  bool validateUser = false;
  bool validateRoomID = false;

  @override
  void dispose() {
    usernameController.dispose();
    roomIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join a Chat Room"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                errorText: validateUser ? "username cant be empty" : null,
                border: const OutlineInputBorder(),
                hintText: 'Enter your username',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: roomIDController,
              decoration: InputDecoration(
                errorText: validateRoomID ? "roomID cant be empty" : null,
                border: OutlineInputBorder(),
                hintText: 'Enter roomID to join others',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    validateUser = usernameController.text.isEmpty;
                    validateRoomID = roomIDController.text.isEmpty;
                    if (validateRoomID == false & (validateUser == false)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPage(
                                  roomID: roomIDController.text,
                                  username: usernameController.text,
                                )),
                      );
                    }
                  });
                },
                child: const Text("Join"))
          ],
        ),
      ),
    );
  }
}
