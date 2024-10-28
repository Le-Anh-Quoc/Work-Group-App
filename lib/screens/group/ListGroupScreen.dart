// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/models/channel_model.dart';
import 'package:ruprup/services/channel_service.dart';
import 'package:ruprup/widgets/bottomNav/CustomAppbar.dart';
import 'package:ruprup/widgets/group/GroupWidget.dart';

class ListGroupScreen extends StatefulWidget {
  const ListGroupScreen({super.key});

  @override
  State<ListGroupScreen> createState() => _ListGroupScreenState();
}

class _ListGroupScreenState extends State<ListGroupScreen> 
with AutomaticKeepAliveClientMixin<ListGroupScreen>{
  final ChannelService _channelService = ChannelService();
  List<Channel> _userChannels = [];
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
      List<Channel> userChannels = await _channelService.getChannelsForCurrentUser(currentUserId!);
      // ignore: avoid_print
      print(userChannels);
      setState(() {
        _userChannels = userChannels;
        isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
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
      appBar: CustomAppBar(title: 'Groups', actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[50],
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_month,
                  color: Colors.black, size: 30),
              onPressed: () {
                
              },
            ),
          )
        ],),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshGroups, // Kéo từ trên xuống để làm mới
              child: _userChannels.isEmpty
                  ? const Center(child: Text("No groups found"))
                  : ListView.builder(
                      itemCount: _userChannels.length,
                      itemBuilder: (context, index) {
                        final channel = _userChannels[index];
                        return Container(
                          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: GroupWidget(channelId: channel.channelId),
                        );
                      },
                    ),
            ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}
