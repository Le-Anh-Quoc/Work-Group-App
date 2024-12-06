import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:ruprup/services/file_service.dart';
import 'package:ruprup/services/folder_service.dart';

class StorageService {
  final FolderService folderService = FolderService();
  final FileService fileService = FileService();

  // Lấy tất cả file và folder theo folderId
  // Future<Map<String, dynamic>> getFolderContents(String folderId) async {
  //   final folders = await folderService.getFoldersByParentId(folderId);
  //   final files = await fileService.getFilesByFolderId(folderId);

  //   return {
  //     'folders': folders,
  //     'files': files,
  //   };
  // }

  Future<String> uploadFileToFirebaseStorage(
      File file, String folderName) async {
    String fileName = basename(file.path);
    Reference storageRef =
        FirebaseStorage.instance.ref().child('$folderName/$fileName');

    UploadTask uploadTask = storageRef.putFile(file);

    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }
}
