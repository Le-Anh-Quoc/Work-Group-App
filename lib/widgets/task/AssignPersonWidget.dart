import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ruprup/services/user_service.dart';

class AssignPersonWidget extends StatefulWidget {
  final String memberId;
  const AssignPersonWidget({Key? key, required this.memberId})
      : super(key: key);

  @override
  _AssignPersonWidgetState createState() => _AssignPersonWidgetState();
}

class _AssignPersonWidgetState extends State<AssignPersonWidget> {
  UserService _userService = UserService();

  String? nameMember;

  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _getNameMember();
  }

  void _getNameMember() async {
    try {
      String name = await _userService.getFullNameByUid(widget.memberId);
      setState(() {
        nameMember = name; // Cập nhật tên thành viên
      });
    } catch (error) {
      setState(() {
        nameMember = 'Error'; // Cập nhật nếu có lỗi
      });
    }
  }

  int randomIndex() {
    // Tạo một instance của Random
    Random random = Random();

    // Tạo số ngẫu nhiên từ 1 đến 10 (bao gồm cả 10)
    return random.nextInt(5) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: Stack(
        alignment: Alignment.topRight, // Align tick on the top right
        children: [
          Container(
            width: 120,
            height: 80,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/women/1.jpg',
                  ),
                  radius: 20,
                ),
                //SizedBox(height: 8),
                Text(
                  nameMember ?? 'Loading...',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
