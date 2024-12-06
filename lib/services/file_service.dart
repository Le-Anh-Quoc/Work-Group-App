import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/channel/file_model.dart';

class FileService {
  final CollectionReference channelCollection =
      FirebaseFirestore.instance.collection('channel');

  // 1. Tạo File trong một Channel
  Future<FileModel> createFile(String channelId, FileModel file) async {
    final fileCollection = channelCollection.doc(channelId).collection('files');
    final newDoc = fileCollection.doc(); // Tạo document mới với ID tự động
    final newFile = FileModel(
      id: newDoc.id, // Sử dụng ID tự động của Firebase
      name: file.name,
      folderId: file.folderId,
      downloadUrl: file.downloadUrl,
      createdAt: file.createdAt,
      createdBy: file.createdBy,
    );
    await newDoc.set(newFile.toMap()); // Lưu file mới vào Firestore
    return newFile; // Trả về file đã tạo
  }

  // 2. Lấy File theo ID trong một Channel
  Future<FileModel?> getFileById(String channelId, String fileId) async {
    final fileCollection = channelCollection.doc(channelId).collection('files');
    final docSnapshot = await fileCollection.doc(fileId).get();
    if (docSnapshot.exists) {
      return FileModel.fromMap(docSnapshot.data() as Map<String, dynamic>, fileId);
    }
    return null;
  }

  // 3. Cập nhật File trong một Channel
  Future<void> updateFile(String channelId, String fileId, Map<String, dynamic> updatedData) async {
    final fileCollection = channelCollection.doc(channelId).collection('files');
    await fileCollection.doc(fileId).update(updatedData);
  }

  // 4. Xóa File trong một Channel
  Future<void> deleteFile(String channelId, String fileId) async {
    final fileCollection = channelCollection.doc(channelId).collection('files');
    await fileCollection.doc(fileId).delete();
  }

  // 5. Lấy tất cả file theo folderId trong một Channel
  Future<List<FileModel>> getFilesByFolderId(String channelId, String folderId) async {
    final fileCollection = channelCollection.doc(channelId).collection('files');
    Query query = fileCollection.where('folderId', isEqualTo: folderId);

    final querySnapshot = await query.get();

    return querySnapshot.docs
        .map((doc) => FileModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
