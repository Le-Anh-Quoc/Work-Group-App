// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/providers/channel_provider.dart';
import 'package:ruprup/screens/group/AddGroupScreen.dart';
import 'package:ruprup/screens/group/EventCalendarScreen.dart';
import 'package:ruprup/widgets/bottomNav/CustomAppbar.dart';
import 'package:ruprup/widgets/group/GroupWidget.dart';

class ListGroupScreen extends StatefulWidget {
  const ListGroupScreen({super.key});

  @override
  State<ListGroupScreen> createState() => _ListGroupScreenState();
}

class _ListGroupScreenState extends State<ListGroupScreen> {
  @override
  Widget build(BuildContext context) {
    final listChannelPersonal =
        Provider.of<ChannelProvider>(context, listen: false)
            .listChannelPersonal;

    return Scaffold(
      appBar: CustomAppBar(
        isHome: false,
        title: 'Groups',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[50],
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_month,
                  color: Colors.black, size: 30),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EventCalendarScreen()),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        child: Stack(
          children: [
            listChannelPersonal.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          size: 80,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No groups found!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create a group to start collaborating.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Số cột là 2
                      crossAxisSpacing: 16.0, // Khoảng cách giữa các cột
                      mainAxisSpacing: 16.0, // Khoảng cách giữa các hàng
                      childAspectRatio:
                          1.3, // Tỉ lệ chiều rộng/chiều cao của mỗi ô
                    ),
                    itemCount: listChannelPersonal.length,
                    itemBuilder: (context, index) {
                      final channel = listChannelPersonal[index];
                      return GroupWidget(channel: channel);
                    },
                  ),
            Positioned(
              bottom: 40, // Khoảng cách từ đáy
              right: 30, // Khoảng cách từ phải
              child: Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Material(
                    color: Colors.blue,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddGroupScreen(),
                          ),
                        );
                      },
                      child: const SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.add, size: 30, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
