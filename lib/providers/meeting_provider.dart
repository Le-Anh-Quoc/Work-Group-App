import 'package:flutter/material.dart';
import 'package:ruprup/models/channel/meeting_model.dart';
import 'package:ruprup/services/meeting_service.dart';

class MeetingProvider with ChangeNotifier {
  final MeetingService _meetingService = MeetingService();

  //Stream<List<Meeting>> allChannelMeetings = [] as Stream<List<Meeting>>;    // list all meeting of channel
  List<Meeting> upcomingMeetings = [];      // list meeting upcoming

  Future<void> fetchUpcomingMeetings(List<String> channelIds) async {
    upcomingMeetings = await _meetingService.getUpcomingMeetings(channelIds);
    notifyListeners();
  }

  Stream<List<Meeting>> fetchAllChannelMeetings(String channelId) {
    return _meetingService.getAllMeetings(channelId);
  }
}
