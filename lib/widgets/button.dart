import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/services/user_service.dart';

class ButtonAccept extends StatelessWidget {
  const ButtonAccept({super.key, required this.idSenderRequest});

  final String idSenderRequest;

  @override
  Widget build(BuildContext context) {
    UserService user = UserService();
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
            color: Colors.blue, borderRadius: BorderRadius.circular(8.0)),
        child: const Center(
          child: Text(
            "Accept",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      onTap: () {
        user.acceptFriendRequest(
            FirebaseAuth.instance.currentUser!.uid, idSenderRequest);
      },
    );
  }
}

class ButtonRefuse extends StatelessWidget {
  const ButtonRefuse({super.key, required this.idSenderRequest});
  final String idSenderRequest;
  @override
  Widget build(BuildContext context) {
    UserService user = UserService();
    return GestureDetector(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 193, 190, 190),
              borderRadius: BorderRadius.circular(8.0)),
          child: const Center(
            child: Text(
              "Refuse",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        onTap: () {
          user.rejectFriendRequest(
              FirebaseAuth.instance.currentUser!.uid, idSenderRequest);
        });
  }
}
