// ignore_for_file: file_names

import 'package:flutter/material.dart';

class FieldWidget extends StatefulWidget {
  final Icon icon;
  final String nameField;
  final bool isPass;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const FieldWidget({
    super.key,
    required this.icon,
    required this.nameField,
    required this.isPass,
    required this.controller,
    this.validator,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FieldWidgetState createState() => _FieldWidgetState();
}

class _FieldWidgetState extends State<FieldWidget> {
  late bool isPasswordVisible;

  @override
  void initState() {
    super.initState();
    isPasswordVisible = widget.isPass;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.icon,
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey[200],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nameField,
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    obscureText: isPasswordVisible,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero),
                  ),
                ),
              ],
            ),
          ),
          if (widget.isPass)
            IconButton(
              color: Colors.grey[400],
              icon: Icon(
                isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
        ],
      ),
    );
  }
}
