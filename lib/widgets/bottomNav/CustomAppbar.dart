// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:ruprup/screens/notification/NotificationScreen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final defaultNotificationIcon = Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[50],
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications_none_rounded,
            color: Colors.black, size: 30),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationScreen(),
            ),
          );
        },
      ),
    );

    // Tạo danh sách actions với tối đa một widget khác
    List<Widget> appBarActions = [];

    if (actions != null && actions!.isNotEmpty) {
      appBarActions.add(actions!.first);
    }
    appBarActions.add(defaultNotificationIcon);

    return AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: const CircleAvatar(
              backgroundImage:
                  NetworkImage('https://picsum.photos/200/300?random=1'),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: appBarActions);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
