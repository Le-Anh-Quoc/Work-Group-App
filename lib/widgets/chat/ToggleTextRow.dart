// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ToggleTextRow extends StatefulWidget {
  const ToggleTextRow({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ToggleTextRowState createState() => _ToggleTextRowState();
}

class _ToggleTextRowState extends State<ToggleTextRow> {
  // Biến theo dõi đoạn văn bản đang được chọn
  String selectedText = 'Message'; // Mặc định "Message" được chọn

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedText = 'Message';
              });
            },
            child: Text(
              "Message",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: selectedText == 'Message' ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedText = 'Group';
              });
            },
            child: Text(
              "Group",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: selectedText == 'Group' ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
