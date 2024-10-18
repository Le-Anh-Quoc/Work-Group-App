import 'package:flutter/material.dart';

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


class Postwidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return 
       Container(
        padding: const EdgeInsets.only(top: 10,bottom: (10)),
        decoration: BoxDecoration(color: Colors.black),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildNotificationTile(
            "Lương Trần Nhật Khiết",
            "13/7 16:26",
            "Chào các bạn.\nCác bạn chưa đăng ký TTNN2 và sẽ đăng ký trong năm tới vui lòng tham gia thêm vào nhóm Facebook này nhé.\n https://www.facebook.com/groups/hcmue.thuctap/ \n TTNN2 các bạn có thể chủ động liên hệ hoặc nhờ Khoa hỗ trợ kết nối các doanh nghiệp như Kyanon, FSOFT, Bảo Kim, Khoa Vũ, Hinnova, eton... Chuẩn bị sẵn portfolio, CV cá nhân.",
            
          ),
          _buildReplyTile(
            "Nguyễn Duy Tân",
            "16/7 7:48",
            "Bạn nào cần thực tập vui lòng gửi email đính kèm CV cá nhân về khietltn@hcmue.edu.vn. Chiều nay Thầy chốt danh sách gửi đi 1 đợt.",
          ),
          _senReply(),
          ]
        )
      
        
       );
  }

  Widget _buildNotificationTile(
    String name,
    String time,
    String content1,
  ) {
    return Card(
      color: Colors.grey[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(name, time),
            const SizedBox(height: 8),
            Text(content1, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyTile(String name, String time, String note) {
      return Card(
    color: Colors.grey[300],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            child: Text(name.split(' ').map((e) => e[0]).take(2).join(''),),
          ),
          const SizedBox(width: 12), 

          // Phần nội dung
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên và thời gian trong một hàng
                Row(
                  
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),
                    ),
                    const SizedBox(width: 15,),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Khoảng cách giữa tên và ghi chú
    
                  Text(
                    note,
                    style: TextStyle(fontSize: 18),
                  ),
            
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }
  Widget _senReply(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey[300], 
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Trả lời...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () {

              print('Tin nhắn đã gửi!');
            },
          ),
        ],
      ),
    );
  }
  Widget _buildHeader(String name, String time) {
    return Row(
      children: [
        CircleAvatar(
          child: Text(name.split(' ').map((e) => e[0]).take(2).join(''),),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
              Text(time, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}