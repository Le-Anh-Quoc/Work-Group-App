// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/screens/notification/NotificationScreen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String title;
  final List<Widget>? actions;
  final bool isHome;
  const CustomAppBar({super.key, required this.title, this.actions, this.leading, required this.isHome});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).currentUser;
    final defaultNotificationIcon = Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[50],
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications_none_rounded, size: 30),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>  NotificationScreen(userId: currentUser!.userId),
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
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            fontSize: isHome ? 18 : 22,
            fontWeight: isHome ? null : FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: appBarActions);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
