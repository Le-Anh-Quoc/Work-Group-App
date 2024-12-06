import 'package:cloud_firestore/cloud_firestore.dart';

class Folder {
  late final String id; // ID của folder
  final String name; // Tên folder
  final String? parentFolderId; // ID folder cha (null nếu là folder gốc)
  final DateTime createdAt; // Thời gian tạo
  final String createdBy; // ID người tạo
  //List<Folder>? subFolders; // Danh sách folder con (nếu có)

  Folder({
    required this.id,
    required this.name,
    this.parentFolderId,
    required this.createdAt,
    required this.createdBy,
    //this.subFolders,
  });

  // Chuyển từ Map (dữ liệu từ Firestore hoặc MongoDB) sang Folder object
  factory Folder.fromMap(Map<String, dynamic> map, String documentId) {
    return Folder(
      id: documentId,
      name: map['name'] as String,
      parentFolderId: map['parentFolderId'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] as String,
      //subFolders: [], // Mặc định là rỗng, sau này có thể thêm folder con bằng đệ quy
    );
  }

  // Chuyển từ Folder object sang Map (để lưu vào Firestore hoặc MongoDB)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'parentFolderId': parentFolderId,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }
}
