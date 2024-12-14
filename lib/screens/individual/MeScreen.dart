// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/screens/individual/EditMeScreen.dart';
import 'package:ruprup/widgets/me/TaskWidget.dart';

class PersonalScreen extends StatefulWidget {
  final UserModel? profileUser;
  const PersonalScreen({super.key, this.profileUser});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    bool isCurrentUser = currentUser!.userId ==
        widget.profileUser
            ?.userId; // kiểm tra xem userId truyền vào có phải người dùng hiện tại không

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context); // Quay lại khi nhấn nút
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
              fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://picsum.photos/200/300?random=${1}'),
                      radius: 40,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.fullname,
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(currentUser.email,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            )),
                      ],
                    ),
                    !isCurrentUser
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.message_outlined,
                                color: Colors.grey, size: 25))
                        : IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => EditMeScreen(
                                          profileUser: currentUser,
                                        )),
                              );
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.grey,
                              size: 25,
                            ))
                  ],
                ),
              ),
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
                      child: const Text('Add Friend',
                          style: TextStyle(color: Colors.white)),
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
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Projects',
                          style: TextStyle(color: Colors.grey, fontSize: 15))
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
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Tasks', style: TextStyle(color: Colors.grey))
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
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Groups', style: TextStyle(color: Colors.grey))
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    );
  }
}
