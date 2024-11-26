import 'package:flutter/material.dart';
import 'package:ruprup/models/channel/channel_model.dart';

class ChannelProvider extends ChangeNotifier {
  Channel? _selectedChannel;

  Channel? get selectedChannel => _selectedChannel;

  // Hàm để cập nhật Channel đang được chọn và thông báo cho các widget liên quan
  void setChannel(Channel channel) {
    _selectedChannel = channel;
    notifyListeners();
  }
}