import 'package:flutter/material.dart';

class  NewMemberWidget extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onSelected;

  const NewMemberWidget({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      leading: const CircleAvatar(
        radius: 22,
        backgroundImage:
            NetworkImage('https://picsum.photos/200/300?random=${1}'),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected
              ? FontWeight.bold
              : FontWeight.normal, // In đậm khi được chọn
        ),
      ),
      trailing: GestureDetector(
        child: isSelected
            ? const Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 28,
              )
            : const Icon(
                Icons.circle_outlined,
                color: Colors.blue,
                size: 28,
              ),
      ),
      tileColor: isSelected
          ? Colors.grey.withOpacity(0.1)
          : Colors.transparent, // Nền hơi ngả màu khi được chọn
      onTap: onSelected, // Kích hoạt khi nhấn vào toàn bộ ListTile
    );
  }
}