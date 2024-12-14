// ignore_for_file: unused_field

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/services/image_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';

class EditMeScreen extends StatefulWidget {
  final UserModel profileUser;
  const EditMeScreen({super.key, required this.profileUser});

  @override
  State<EditMeScreen> createState() => _EditMeScreenState();
}

class _EditMeScreenState extends State<EditMeScreen> {
  // Controllers for the TextFields
  late TextEditingController emailController = TextEditingController();
  late TextEditingController nameController = TextEditingController();

   final ImageService _imageService = ImageService();

  final ImagePicker _picker = ImagePicker();
  File? _imageFile; // Biến để lưu tệp ảnh đã chọn
  String? _imageUrl; // Biến để lưu URL của ảnh sau khi upload

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.profileUser.email);
    nameController = TextEditingController(text: widget.profileUser.fullname);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Lưu tệp ảnh đã chọn
      });

      // Upload ảnh lên Firebase Storage
      _imageUrl =
          await _imageService.uploadImageToFirebaseStorage(_imageFile!, true);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.blue, size: 20)),
        title: const Text('Edit profile',
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // const CircleAvatar(
                    //   radius: 45,
                    //   backgroundImage: NetworkImage(
                    //       'https://picsum.photos/200/300?random=${1}'),
                    // ),
                    if (widget.profileUser.profilePictureUrl == '')
                      PersonalInitialsAvatar(name: widget.profileUser.fullname, size: 80),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.blue,
                            size: 12,
                          ),
                          onPressed: () {
                            _pickImage();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.profileUser.fullname,
                  style: const TextStyle(color: Colors.blue, fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.profileUser.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              customInputField('Email address', emailController),
              customInputField('Fullname', nameController)
            ],
          )
        ],
      ),
    );
  }

  Widget customInputField(String fieldName, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldName,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          TextField(
            controller: controller,
            cursorColor: Colors.blue,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
