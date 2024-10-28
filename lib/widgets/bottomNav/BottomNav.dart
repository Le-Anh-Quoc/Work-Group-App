// ignore_for_file: file_names

import 'package:flutter/material.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
 //final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    //required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0), // Thay đổi khoảng cách để mở rộng vùng bấm
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 35,
            ),
            // Text(
            //   label,
            //   style: TextStyle(
            //     color: isSelected ? Colors.blue : Colors.grey,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
