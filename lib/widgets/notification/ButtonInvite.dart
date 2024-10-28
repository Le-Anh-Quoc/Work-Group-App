// ignore_for_file: file_names

import 'package:flutter/material.dart';

// button chấp nhận hoặc từ chối lời mời kết bạn (false: từ chối, true: chấp nhận)
class ButtonInvite extends StatelessWidget {
  final bool typeButton;
  const ButtonInvite({super.key, required this.typeButton});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: typeButton ? Colors.blue : Colors.white,
        foregroundColor: typeButton ? Colors.white : Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        )
      ),
      child: Text(typeButton ? 'Accept' : 'Refuse')
    );
  }
}
