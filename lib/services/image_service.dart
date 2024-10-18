import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class ImageService {
  Future<String> uploadImageToFirebaseStorage(File imageFile, bool isAvatar) async {
    String fileName = basename(imageFile.path); // Lấy tên tệp
    String folder = isAvatar ? 'avatars' : 'messages';
    Reference storageRef =
        FirebaseStorage.instance.ref().child('$folder/$fileName');

    UploadTask uploadTask = storageRef.putFile(imageFile);

    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref
        .getDownloadURL(); // Trả về URL của ảnh sau khi upload
  }
}
