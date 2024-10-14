import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/widgets/me/TaskWidget.dart';

class PersonalScreen extends StatefulWidget {
  final String userId;
  const PersonalScreen({super.key, required this.userId});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  @override
  Widget build(BuildContext context) {
    String currentUserId =
        FirebaseAuth.instance.currentUser!.uid; // lấy userId hiện tại
    bool isCurrentUser = currentUserId ==
        widget
            .userId; // kiểm tra xem userId truyền vào có phải người dùng hiện tại không

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(bottom: isCurrentUser ? 56.0 : 0),
        child: Column(
          children: [
            // Stack chứa AppBar với hình nền và hiệu ứng mờ
            Stack(
              children: [
                // Hình nền của AppBar
                Container(
                  height: kToolbarHeight + 50, // Chiều cao của AppBar
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://picsum.photos/200/300?random=${1}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Lớp hiệu ứng mờ
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
                // AppBar
                AppBar(
                  leading: !isCurrentUser ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Quay lại khi nhấn nút
                    },
                  ) : null,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                    )
                  ],
                ),
              ],
            ),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Center(
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://picsum.photos/200/300?random=${1}'),
                              radius: 40,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "Anh Quoc IT",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const Text("leanhquocit@gmail.com",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              )),
                          const SizedBox(height: 18),
                          const Text("Study, study more, study forever",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400)),
                          const SizedBox(height: 15),
                          if (!isCurrentUser)
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Xử lý logic gửi yêu cầu kết bạn
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                  child: Text('Add Friend', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Column(
                                children: [
                                  Text('0',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text('Friends',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15))
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: const Color.fromARGB(255, 219, 203, 203),
                              ),
                              const Column(
                                children: [
                                  Text('0',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text('Tasks',
                                      style: TextStyle(color: Colors.grey))
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: const Color.fromARGB(255, 219, 203, 203),
                              ),
                              const Column(
                                children: [
                                  Text('0',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text('Groups',
                                      style: TextStyle(color: Colors.grey))
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TaskIndivi(
                                      percentTask: '23',
                                      typeTask: 'Total Task',
                                      numberTask: '23',
                                      color: Colors.blue),
                                  TaskIndivi(
                                      percentTask: '23',
                                      typeTask: 'Complete Task',
                                      numberTask: '23',
                                      color: Colors.green),
                                ],
                              ),
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TaskIndivi(
                                      percentTask: '23',
                                      typeTask: 'Uncomplete Task',
                                      numberTask: '23',
                                      color: Colors.red),
                                  TaskIndivi(
                                      percentTask: '23',
                                      typeTask: 'Progressing Task',
                                      numberTask: '23',
                                      color: Colors.teal),
                                ],
                              ),
                            ],
                          ),
                        ],
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
