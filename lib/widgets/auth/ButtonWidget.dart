// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String nameButton;
  final VoidCallback onTap;

  const ButtonWidget({super.key, required this.nameButton, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 60,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: Colors.blue),
          alignment: Alignment.center,
          child: Text(nameButton,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
    );
  }
}
