// import 'package:flutter/material.dart';

// class PostWidget extends StatelessWidget {
//   final String userName; // Tên người dùng
//   final String timePost; // Thời gian đăng
//   final String content; // Nội dung bài đăng
//   final List<List<String>> reply;
//   //final String avatarUrl; // URL hình đại diện

//   const PostWidget({
//     super.key,
//     required this.userName,
//     required this.timePost,
//     required this.content,
//     required this.reply,
//     //required this.avatarUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController commentController = TextEditingController();
//     return Card(
//       color: Colors.grey[300],
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0),
//       side: BorderSide(
//         width: 0.5,
//         color: Colors.black,
//       )),
//       margin: EdgeInsets.zero,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//             children: [
//         CircleAvatar(
//           child: Text(userName.split(' ').map((e) => e[0]).take(2).join(''),),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(userName, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,)),
//               Text(timePost, style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//         ),
//       ],
//     ),
//             const SizedBox(height: 8),
//             Text(content, style: TextStyle(fontSize: 18)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: file_names

import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Đổ bóng cho card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Bo góc cho card
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Xử lý sự kiện nhấn ở đây
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15), // Nền trắng
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      'Anh Quoc'.split(' ').map((e) => e[0]).take(2).join(''),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Anh Quoc',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '5:20, Oct 20',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Meeting notice',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'On October 19th we will have a meeting at 7pm, please turn on the cam, wear formal clothes and be on time. Thank you',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 15), // Khoảng cách trước TextField
              TextField(
                decoration: InputDecoration(
                  hintText: 'Reply...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.reply,
                      color: Colors.blueAccent), // Biểu tượng bên trái
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// class NotificationCard extends StatelessWidget {
//   final String name;
//   final String time;
//   final String content;

//   const NotificationCard({
//     required this.name,
//     required this.time,
//     required this.content,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.grey[100],
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       margin: EdgeInsets.symmetric(vertical: 8),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(name, time),
//             const SizedBox(height: 8),
//             Text(
//               content,
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(String name, String time) {
//     return Row(
//       children: [
//         CircleAvatar(
//           child: Text(name.split(' ').map((e) => e[0]).take(2).join('')),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(name,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//               Text(time, style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class ReplyCard extends StatelessWidget {
//   final String name;
//   final String time;
//   final String note;

//   const ReplyCard({
//     required this.name,
//     required this.time,
//     required this.note,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.grey[100],
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       margin: EdgeInsets.symmetric(vertical: 4),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               child: Text(name.split(' ').map((e) => e[0]).take(2).join('')),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         name,
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 17),
//                       ),
//                       const SizedBox(width: 15),
//                       Text(
//                         time,
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     note,
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SendReply extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       color: Colors.grey[100],
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               style: TextStyle(color: Colors.black),
//               decoration: InputDecoration(
//                 hintText: 'Trả lời...',
//                 hintStyle: TextStyle(color: Colors.grey),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.send, color: Colors.blue),
//             onPressed: () {
//               print('Tin nhắn đã gửi!');
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
