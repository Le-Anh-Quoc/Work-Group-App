import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/models/group_model.dart';
import 'package:ruprup/services/group_service.dart';
import 'package:ruprup/widgets/group/GroupWidget.dart';

class ListGroupScreen extends StatefulWidget {
  const ListGroupScreen({super.key});

  @override
  State<ListGroupScreen> createState() => _ListGroupScreenState();
}

class _ListGroupScreenState extends State<ListGroupScreen> 
with AutomaticKeepAliveClientMixin<ListGroupScreen>{
  GroupService _groupService = GroupService();
  List<Group> _userGroups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserGroups();
  }

  // Hàm để tải dữ liệu groups
  Future<void> _loadUserGroups() async {
    try {
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      List<Group> userGroups = await _groupService.getGroupsForCurrentUser(currentUserId!);
      setState(() {
        _userGroups = userGroups;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching groups: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm làm mới dữ liệu khi kéo từ trên xuống
  Future<void> _refreshGroups() async {
    setState(() {
      isLoading = true; // Hiển thị loading trong lúc đang làm mới dữ liệu
    });
    await _loadUserGroups(); // Gọi lại hàm lấy dữ liệu
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshGroups, // Kéo từ trên xuống để làm mới
              child: _userGroups.isEmpty
                  ? const Center(child: Text("No groups found"))
                  : ListView.builder(
                      itemCount: _userGroups.length,
                      itemBuilder: (context, index) {
                        final group = _userGroups[index];
                        return Container(
                          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: GroupWidget(groupId: group.groupId),
                        );
                      },
                    ),
            ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}
