// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class StorageService {
  final String _file = 'file';
  // Lấy tất cả file và folder theo folderId
  // Future<Map<String, dynamic>> getFolderContents(String folderId) async {
  //   final folders = await folderService.getFoldersByParentId(folderId);
  //   final files = await fileService.getFilesByFolderId(folderId);

  //   return {
  //     'folders': folders,
  //     'files': files,
  //   };
  // }

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFileFolderToFirebaseStorage(
      File file, String folderName) async {

    String fileFolder = 'FileFolder';
    String fileName = basename(file.path);
    Reference storageRef =
        FirebaseStorage.instance.ref().child('$_file/$fileFolder/$folderName/$fileName');

    UploadTask uploadTask = storageRef.putFile(file);

    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> uploadFileTaskToFirebaseStorage(
      File file, String taskId) async {

    String fileTask = 'FileTask';
    String fileName = basename(file.path);
    Reference storageRef =
        FirebaseStorage.instance.ref().child('$_file/$fileTask/$taskId/$fileName');

    UploadTask uploadTask = storageRef.putFile(file);

    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> uploadFileCommentToFirebaseStorage(
      File file, String commentId) async {

    String fileComment = 'FileComment';
    String fileName = basename(file.path);
    Reference storageRef =
        FirebaseStorage.instance.ref().child('$_file/$fileComment/$commentId/$fileName');

    UploadTask uploadTask = storageRef.putFile(file);

    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> deleteFileFromFirebaseStorage(String fileDownloadUrl) async {
    try {
      // Xóa tệp từ Firebase Storage
      final fileRef = _storage.refFromURL(fileDownloadUrl);
      await fileRef.delete();
      print("File deleted from Firebase Storage");

      //await _firestore.collection('tasks').doc(fileDownloadUrl).delete();
      print("File data deleted from Firestore");
    } catch (e) {
      print("Error deleting file: $e");
    }
  }
}
