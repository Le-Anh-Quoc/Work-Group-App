import 'package:flutter/material.dart';
import 'package:ruprup/widgets/button.dart';

class NotificationFriendRequest extends StatelessWidget {
  const NotificationFriendRequest(
      {super.key, required this.idSenderRequest, required this.message});
  final String message;
  final String idSenderRequest;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundImage:
            NetworkImage('https://picsum.photos/200/300?random=${1}'),
      ),
      title: Column(
        children: [
          Text(message),
          const SizedBox(height: 8.0), // Khoảng cách giữa title và các nút
          Row(
            children: [
              ButtonAccept(idSenderRequest: idSenderRequest),
              const SizedBox(width: 8.0), // Khoảng cách giữa các nút
              ButtonRefuse(idSenderRequest: idSenderRequest),
            ],
          ),
          const Divider(color: Colors.black)
        ],
      ),
    );
  }
}

class NotificationGroup extends StatelessWidget {
  const NotificationGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
