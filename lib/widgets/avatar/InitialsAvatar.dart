import 'package:flutter/material.dart';

// tạo avatar bằng chữ cái đầu của tên
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;

  const InitialsAvatar({
    Key? key,
    required this.name,
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tách tên thành các từ và lấy chữ cái đầu của từng từ
    String initials = name.isNotEmpty
        ? name.split(' ').take(2).map((word) => word[0].toUpperCase()).join('')
        : "?"; // Nếu tên rỗng, hiển thị dấu hỏi

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors
            .blue, // Màu nền của hình đại diện, bạn có thể thay đổi màu này
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}