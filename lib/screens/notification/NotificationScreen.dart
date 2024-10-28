// ignore_for_file: unused_field, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:ruprup/services/notification_service.dart';
import 'package:ruprup/widgets/notification/NotificationWidget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationService notification = NotificationService();
  List<Map<String, dynamic>> _notificationResults = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  void fetchNotifications() async {
    List<Map<String, dynamic>> notifications =
        await notification.getNotificationsOfCurrentUser();
    setState(() {
      _notificationResults = notifications;
    });
    print('Notifications: $notifications');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: Colors.black, size: 28), // Custom icon here
            onPressed: () {
              Navigator.of(context).pop(); // Handles back navigation
            },
          ),
          backgroundColor: Colors.white,
          title: const Text("Notifications",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline_outlined, size: 28))
          ],
        ),
        // body: _notificationResults.isEmpty
        //     ? const Center(child: Text('No notifications'))
        //     : ListView.builder(
        //         itemCount: _notificationResults.length,
        //         itemBuilder: (context, index) {
        //           return const NotificationWidget(isInvite: true);
        //         },
        //       ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              NotificationWidget(notificationTypeString: 'friend'),
              NotificationWidget(notificationTypeString: 'friendInvite'),
              NotificationWidget(notificationTypeString: 'group'),
              NotificationWidget(notificationTypeString: 'groupMeeting'),
              NotificationWidget(notificationTypeString: 'task'),
              NotificationWidget(notificationTypeString: 'project')
            ],
          ),
        ));
  }
}
