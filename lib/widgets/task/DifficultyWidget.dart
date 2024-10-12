import 'package:flutter/material.dart';

class DifficultyTag extends StatefulWidget {
  final String label;
  final Color color;
  final bool isSelected; // Thêm tham số để xác định trạng thái chọn
  final VoidCallback onSelect; // Thêm tham số để xử lý sự kiện chọn

  const DifficultyTag({
    Key? key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  _DifficultyTagState createState() => _DifficultyTagState();
}

class _DifficultyTagState extends State<DifficultyTag> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelect,
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (widget.isSelected)
          Positioned(
            right: 0,
            top: 5,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                shape: BoxShape.circle,
                color: widget.color,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            ),
          )
      ]),
    );
  }
}
