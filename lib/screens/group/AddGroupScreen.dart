import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as type;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ruprup/models/channel_model.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/models/room_model.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/screens/chat/ChatScreen.dart';
import 'package:ruprup/services/chat_service.dart';
import 'package:ruprup/services/friend_service.dart';
import 'package:ruprup/services/channel_service.dart';
import 'package:ruprup/services/image_service.dart';
import 'package:ruprup/services/roomchat_service.dart';
import 'package:ruprup/widgets/group/FieldWidget.dart';
import 'package:ruprup/widgets/group/NewMemberWidget.dart';
import 'package:ruprup/widgets/search/SearchWidget.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  List<String> selectedUsers = []; // List này sẽ chứa user được chọn
  bool isLoading = false;

  final FriendService _friendService = FriendService();
  final ImageService _imageService = ImageService();
  final RoomChatService _roomChatService = RoomChatService();
  List<Map<String, dynamic>> _friendResults = [];
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final ImagePicker _picker = ImagePicker();
  File? _imageFile; // Biến để lưu tệp ảnh đã chọn
  String? _imageUrl; // Biến để lưu URL của ảnh sau khi upload

  @override
  void initState() {
    super.initState();
    //String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    selectedUsers.add(currentUserId);
    _fetchFriendsOfCurrentUser();
  }

  void _fetchFriendsOfCurrentUser() async {
    List<Map<String, dynamic>> results =
        await _friendService.getFriendsOfCurrentUser();
    setState(() {
      _friendResults = results;
    });
  }

  void _toggleSelection(String userId) {
    setState(() {
      if (selectedUsers.contains(userId)) {
        selectedUsers.remove(userId); // Bỏ chọn người dùng
      } else {
        selectedUsers.add(userId); // Chọn người dùng
      }
    });
  }

  void _createGroup() async {
    print(selectedUsers);
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a group name")),
      );
      return;
    }

    if (selectedUsers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Select at least 2 members")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    RoomChat newRoomChat = RoomChat(
      idRoom: '',
      type: 'group',
      userIds: selectedUsers,
      nameRoom: _groupNameController.text,
      imageUrl: _imageUrl,
      createAt: DateTime.now().millisecondsSinceEpoch,
    );

    RoomChat roomChat = await _roomChatService.createRoomChat(newRoomChat);

    setState(() {
      isLoading = false;
    });

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("Group chat created!")),
    // );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(roomChat: roomChat),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Lưu tệp ảnh đã chọn
      });

      // Upload ảnh lên Firebase Storage
      _imageUrl = await _imageService.uploadImageToFirebaseStorage(_imageFile!, true);

      // // Sau khi có URL ảnh, lưu vào Firestore (ví dụ như lưu vào tài liệu của group)
      // if (_imageUrl != null) {
      //   await FirebaseFirestore.instance.collection('groups').add({
      //     'imageUrl': _imageUrl,
      //     'nameRoom': _groupNameController.text,
      //     'createdAt': DateTime.now().millisecondsSinceEpoch,
      //     'userIds': selectedUsers,
      //   });
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
          title: Column(
            children: [
              const Center(
                  child: Text("Create a group",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue))),
              Text("Numbers of member: ${selectedUsers.length - 1}",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _createGroup();
                },
                icon: const Icon(Icons.add, size: 27))
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Stack(children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[50], // Đặt màu nền xanh nhạt
                            shape: BoxShape.circle, // Giữ nút hình tròn
                          ),
                          child: _imageFile != null ?
                          ClipOval(
                            child: Image.file(_imageFile!, width: 50, height: 50, fit: BoxFit.cover),
                          )
                          : IconButton(
                            onPressed: _pickImage,
                            icon: Icon(Icons.image),
                            color: Colors.blue,
                            iconSize: 35,
                          ),
                        ),
                        Positioned(
                          right: 0, // Vị trí góc phải
                          bottom: 0, // Vị trí góc dưới
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white, // Màu nền cho dấu cộng
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                color: Colors.blue,
                                Icons.add_circle, // Dấu cộng
                                size: 18, // Kích thước của dấu cộng
                              ),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(
                          width:
                              30), // Khoảng cách giữa CircleAvatar và TextField
                      Expanded(
                        // Sử dụng Expanded để TextField chiếm phần không gian còn lại
                        child: Column(
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Name your group',
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 17),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide
                                      .none, // Remove default underline
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide
                                      .none, // Remove default underline on focus
                                ),
                              ),
                              controller: _groupNameController,
                            ),
                            const DashedUnderline(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                CustomSearchField(),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: _friendResults.length,
                        itemBuilder: (context, index) {
                          String nameUserChat =
                              _friendResults[index]['fullname'];
                          String idUserChat = _friendResults[index]['uid'];
                          bool isSelected = selectedUsers.contains(idUserChat);
                          return NewMemberWidget(
                            name: nameUserChat,
                            isSelected: isSelected,
                            onSelected: () {
                              _toggleSelection(
                                  idUserChat); // Cập nhật trạng thái người dùng được chọn
                            },
                          );
                        }))
              ],
            )));
  }
}
