// ignore_for_file: file_names

import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  final Future<String> name; // Future chứa tên
  final double size;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: name,
      builder: (context, snapshot) {
        String initials = "?"; // Giá trị mặc định khi chưa có tên

        if (snapshot.connectionState == ConnectionState.waiting) {
          initials = ""; // Có thể hiển thị ký tự hoặc vòng tròn loading nếu cần
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Nếu dữ liệu đã có và không rỗng, tạo chữ cái đầu
          initials = snapshot.data!.split(' ').take(2).map((word) => word[0].toUpperCase()).join('');
        }

        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue, // Màu nền của hình đại diện
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size/2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class PersonalInitialsAvatar extends StatelessWidget {
  final String name; // String chứa tên
  final double size;

  const PersonalInitialsAvatar({
    super.key,
    required this.name,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    // Tách tên và tạo chữ cái đầu
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((word) => word[0].toUpperCase()).join('')
        : "?";

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue, // Màu nền của hình đại diện
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: size / 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
