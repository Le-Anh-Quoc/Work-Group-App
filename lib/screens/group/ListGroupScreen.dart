// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/models/channel_model.dart';
import 'package:ruprup/screens/group/AddGroupScreen.dart';
import 'package:ruprup/screens/group/EventCalendarScreen.dart';
import 'package:ruprup/services/channel_service.dart';
import 'package:ruprup/widgets/bottomNav/CustomAppbar.dart';
import 'package:ruprup/widgets/group/GroupWidget.dart';

class ListGroupScreen extends StatefulWidget {
  const ListGroupScreen({super.key});

  @override
  State<ListGroupScreen> createState() => _ListGroupScreenState();
}

class _ListGroupScreenState extends State<ListGroupScreen>
    with AutomaticKeepAliveClientMixin<ListGroupScreen> {
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
      List<Channel> userChannels =
          await _channelService.getChannelsForCurrentUser(currentUserId!);
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
      appBar: CustomAppBar(
        isHome: false,
        title: 'Groups',
        actions: [
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EventCalendarScreen()),
                );
              },
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 36),
        child: Stack(children: [
          isLoading
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
          Positioned(
            bottom: 30, // Khoảng cách từ đáy
            right: 30, // Khoảng cách từ phải
            child: Container(
              width: 55,
              height: 55,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Material(
                  color: Colors.blue,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddGroupScreen(),
                        ),
                      );
                    },
                    child: const SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(Icons.add, size: 30, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
