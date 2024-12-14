// ignore_for_file: unused_field, file_names, avoid_print

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/models/notification_model.dart';
import 'package:ruprup/services/notification_service.dart';
import 'package:ruprup/widgets/notification/NotificationWidget.dart';

class NotificationScreen extends StatefulWidget {
  
  final String userId;
  const NotificationScreen({super.key, required this.userId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationService notification = NotificationService();
  //List<Map<String, dynamic>> _notificationResults = [];

  // @override
  // void initState() {
  //   super.initState();
  //   fetchNotifications();
  // }

  // void fetchNotifications() async {
  //   List<Map<String, dynamic>> notifications =
  //       await notification.getNotificationsOfCurrentUser();
  //   setState(() {
  //     _notificationResults = notifications;
  //   });
  //   print('Notifications: $notifications');
  // }

  @override
  Widget build(BuildContext context) {
     final  NotificationService notificationService= NotificationService();
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.blue, size: 28), // Custom icon here
            onPressed: () {
              Navigator.of(context).pop(); // Handles back navigation
            },
          ),
          backgroundColor: Colors.white,
          title: const Text("Notifications",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
          centerTitle: true,
          // actions: [
          //   IconButton(
          //       onPressed: () {},
          //       icon: const Icon(Icons.delete_outline_outlined, size: 28, color: Colors.blue,))
          // ],
        ),
        body: SingleChildScrollView(
          child:
        
          // Danh sách bài đăng
          StreamBuilder<List<NotificationUser>>(
            stream: notificationService.getAllNotifica(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No Notifications"));
              }

              final allNotifica = snapshot.data!;

              return ListView.builder(
              itemCount: allNotifica.length,
              itemBuilder: (context, index) {
              final notification = allNotifica[index];
              return NotificationWidget(
                body: notification.body, // Nội dung thông báo
                notificationTypeString: notification.type.value, // Loại thông báo
              );
                          },
              );
            },
          ),
        ));
  }


}
