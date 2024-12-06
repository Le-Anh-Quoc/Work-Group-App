import 'package:flutter/material.dart';
import 'package:ruprup/models/channel/channel_model.dart';
import 'package:ruprup/services/channel_service.dart';

class ChannelProvider extends ChangeNotifier {
  final ChannelService _channelService = ChannelService();

  Channel? _selectedChannel;
  List<Channel> _listChannelPersonal = [];

  Channel? get selectedChannel => _selectedChannel;
  List<Channel> get listChannelPersonal => _listChannelPersonal;

  // Hàm để cập nhật Channel đang được chọn và thông báo cho các widget liên quan
  void setChannel(Channel channel) {
    _selectedChannel = channel;
    notifyListeners();
  }

  void clearChannel() {
    _selectedChannel = null;
    notifyListeners();
  }

  Future<void> fetchChannelsPersonal(String currentUserId) async {
    _listChannelPersonal = await _channelService.getChannelsForCurrentUser(currentUserId);
    notifyListeners();
  }
}