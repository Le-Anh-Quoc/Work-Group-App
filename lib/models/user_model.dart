import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class UserModel {
  final String id;
  final String name;

  UserModel({required this.id, required this.name});

  types.User toTypesUser() => types.User(id: id);
}
