import 'package:flutter/material.dart';
import 'package:ruprup/services/notification_service.dart';
import 'package:ruprup/widgets/notification/notification.dart';

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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 28), // Custom icon here
          onPressed: () {
            Navigator.of(context).pop();  // Handles back navigation
          },
        ),
        backgroundColor: Colors.white,
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline_outlined, size: 28))
        ],
      ),
      body: _notificationResults.isEmpty
          ? Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: _notificationResults.length,
              itemBuilder: (context, index) {
                return NotificationFriendRequest(
                  message: _notificationResults[index]['message'],
                  idSenderRequest: _notificationResults[index]['senderId'],
                );
              },
            ),
    );
  }
}
