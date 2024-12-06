import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/channel/folder_model.dart';

class FolderService {
  final CollectionReference channelCollection =
      FirebaseFirestore.instance.collection('channel');

  // 1. Tạo Folder trong một Channel
  Future<Folder> createFolder(String channelId, Folder folder) async {
    final folderCollection =
        channelCollection.doc(channelId).collection('folders');
    final newDoc = folderCollection.doc(); // Tạo document mới với ID tự động
    final newFolder = Folder(
      id: newDoc.id, // Sử dụng ID tự động của Firebase
      name: folder.name,
      parentFolderId: folder.parentFolderId,
      createdAt: folder.createdAt,
      createdBy: folder.createdBy,
    );
    await newDoc.set(newFolder.toMap()); // Lưu folder mới vào Firestore
    return newFolder; // Trả về folder đã tạo
  }

  // 2. Lấy Folder theo ID trong một Channel
  Future<Folder?> getFolderById(String channelId, String folderId) async {
    final folderCollection =
        channelCollection.doc(channelId).collection('folders');
    final docSnapshot = await folderCollection.doc(folderId).get();
    if (docSnapshot.exists) {
      return Folder.fromMap(
          docSnapshot.data() as Map<String, dynamic>, folderId);
    }
    return null;
  }

  // 3. Cập nhật Folder trong một Channel
  Future<void> updateFolder(String channelId, String folderId,
      Map<String, dynamic> updatedData) async {
    final folderCollection =
        channelCollection.doc(channelId).collection('folders');
    await folderCollection.doc(folderId).update(updatedData);
  }

  // 4. Xóa Folder trong một Channel (và xóa tất cả file và folder con bên trong)
  Future<void> deleteFolder(String channelId, String folderId) async {
    final folderCollection =
        channelCollection.doc(channelId).collection('folders');
    final fileCollection =
        channelCollection.doc(channelId).collection('files');

    // Xóa folder
    await folderCollection.doc(folderId).delete();

    // Xóa tất cả file bên trong folder
    final filesInFolder =
        await fileCollection.where('folderId', isEqualTo: folderId).get();
    for (var doc in filesInFolder.docs) {
      await doc.reference.delete();
    }

    // Xóa tất cả folder con
    final subFolders = await folderCollection
        .where('parentFolderId', isEqualTo: folderId)
        .get();
    for (var doc in subFolders.docs) {
      await deleteFolder(channelId, doc.id); // Đệ quy xóa folder con
    }
  }

  // 5. Lấy tất cả folder con theo parentFolderId trong một Channel
  Future<List<Folder>> getFoldersByParentId(
      String channelId, String parentFolderId) async {
    final folderCollection =
        channelCollection.doc(channelId).collection('folders');
    Query query = folderCollection.where('parentFolderId',
        isEqualTo: parentFolderId);

    final querySnapshot = await query.get();

    return querySnapshot.docs
        .map(
            (doc) => Folder.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
