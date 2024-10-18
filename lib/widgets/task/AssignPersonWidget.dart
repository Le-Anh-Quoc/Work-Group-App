import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ruprup/services/user_service.dart';

class AssignPersonWidget extends StatefulWidget {
  final String memberId;
  final VoidCallback onSelect; // Thêm hàm callback
  const AssignPersonWidget({
    Key? key,
    required this.memberId,
    required this.onSelect, // Truyền callback
  }) : super(key: key);

  @override
  _AssignPersonWidgetState createState() => _AssignPersonWidgetState();
}

class _AssignPersonWidgetState extends State<AssignPersonWidget> {
  final UserService _userService = UserService();
  String? nameMember;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _getNameMember();
  }

  Future<void> _getNameMember() async {
    try {
      String name = await _userService.getFullNameByUid(widget.memberId);
      setState(() {
        nameMember = name;
      });
    } catch (error) {
      setState(() {
        nameMember = 'Error'; // Xử lý lỗi nếu không lấy được tên
      });
    }
  }

  int randomIndex() {
    Random random = Random();
    return random.nextInt(5) + 1; // Tạo số ngẫu nhiên từ 1 đến 5
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected; // Đảo ngược trạng thái isSelected
        });
        widget.onSelect(); // Gọi hàm callback khi nhấn chọn
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: 120,
            height: 80,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/women/${randomIndex()}.jpg', // Ảnh ngẫu nhiên
                  ),
                  radius: 17,
                ),
                const SizedBox(height: 8),
                Text(
                  nameMember ?? 'Loading...', // Hiển thị tên thành viên
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
