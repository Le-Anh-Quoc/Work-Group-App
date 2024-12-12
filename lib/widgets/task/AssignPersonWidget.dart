// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';

class AssignPersonWidget extends StatefulWidget {
  final String memberId;
  final bool isSelected;
  final VoidCallback onSelect; // Thêm hàm callback
  const AssignPersonWidget({
    super.key,
    required this.memberId,
    required this.onSelect, // Truyền callback
    required this.isSelected, 
  });

  @override
  // ignore: library_private_types_in_public_api
  _AssignPersonWidgetState createState() => _AssignPersonWidgetState();
}

class _AssignPersonWidgetState extends State<AssignPersonWidget> {
  final UserService _userService = UserService();
  String nameMember = '';
  //bool isSelected = false;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onSelect(); // Gọi hàm callback khi nhấn chọn
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Column(
              children: [
                // CircleAvatar(
                //   backgroundImage: NetworkImage(
                //     'https://randomuser.me/api/portraits/women/${randomIndex()}.jpg', // Ảnh ngẫu nhiên
                //   ),
                //   radius: 17,
                // ),
                PersonalInitialsAvatar(name: nameMember),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    nameMember, // Hiển thị tên thành viên
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isSelected)
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
