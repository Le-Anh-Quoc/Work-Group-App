import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String userName; // Tên người dùng
  final String timePost; // Thời gian đăng
  final String content; // Nội dung bài đăng
  final String avatarUrl; // URL hình đại diện

  const PostWidget({
    super.key,
    required this.userName,
    required this.timePost,
    required this.content,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = TextEditingController();

    return Card(
      elevation: 2, // Độ nổi của card
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình đại diện và thông tin người dùng
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        timePost,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 8), // Khoảng cách giữa thông tin người dùng và nội dung
            // Nội dung bài đăng
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12), // Khoảng cách dưới nội dung

            // Nút like và TextField
            Row(
              children: [
                Expanded(
                  // Để TextField có thể chiếm không gian còn lại
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: "Reply",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // Bo tròn góc
                        borderSide: BorderSide(color: Colors.grey), // Màu viền
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                    ),
                    onSubmitted: (value) {
                      // Xử lý khi người dùng nhấn Enter
                      print("Bình luận: $value");
                      commentController
                          .clear(); // Xóa nội dung sau khi bình luận
                    },
                  ),
                ),
                const SizedBox(
                    width: 16), // Khoảng cách giữa nút Like và TextField
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined),
                  onPressed: () {
                    // Xử lý khi nhấn nút like
                    print("Đã thích bài đăng");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
