// ignore_for_file: file_names, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/channel/meeting_model.dart';
import 'package:ruprup/providers/channel_provider.dart';
import 'package:ruprup/services/meeting_service.dart';
import 'package:table_calendar/table_calendar.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  late Future<List<Map<String, dynamic>>> _meetingsFuture;

  MeetingService meetingService = MeetingService();

  List<String> channelsCurrentUser = [];

  // late int countEvents;
  // final int countTasks = 4;

  @override
  void initState() {
    super.initState();
    _loadChannelCurrentUser();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _meetingsFuture = meetingService.getMeetingByDayWithChannelNames(
        _selectedDay, channelsCurrentUser);
  }

  Future<int> getMeetingsLength() async {
    final meetings = await _meetingsFuture;
    return meetings.length; // Trả về độ dài danh sách
  }

  void _loadChannelCurrentUser() {
    final listChannelPersonal =
        Provider.of<ChannelProvider>(context, listen: false)
            .listChannelPersonal;

    // Lấy danh sách ID từ listChannelPersonal
    final List<String> channelIds = listChannelPersonal
        .map((channel) =>
            channel.channelId) // Trích xuất channelId từ từng đối tượng
        .toList();

    channelsCurrentUser = channelIds;
  }

  @override
  Widget build(BuildContext context) {
    // final listChannelPersonal =
    //     Provider.of<ChannelProvider>(context, listen: false)
    //         .listChannelPersonal;

    // // Lấy danh sách ID từ listChannelPersonal
    // final List<String> channelIds = listChannelPersonal
    //     .map((channel) =>
    //         channel.channelId) // Trích xuất channelId từ từng đối tượng
    //     .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Nền màu nhạt
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
        ),
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _meetingsFuture =
                        meetingService.getMeetingByDayWithChannelNames(
                      _selectedDay,
                      channelsCurrentUser,
                    );
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonTextStyle: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.blue),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 1)),
                  todayTextStyle: const TextStyle(color: Colors.blue),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // TabBar(
            //   labelColor: Colors.blue,
            //   unselectedLabelColor: Colors.grey,
            //   indicatorColor: Colors.blue,
            //   dividerColor: Colors.transparent,
            //   tabs: [
            //     Tab(
            //       text: 'Events', // Thay số này thành số event thực tế
            //     ),
            //     // Tab(
            //     //   text: 'Tasks', // Thay số này thành số task thực tế
            //     // ),
            //   ],
            // ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _meetingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 80,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No meetings found for this date.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final meetingsWithChannelNames = snapshot.data!;

                  return ListView.builder(
                    itemCount: meetingsWithChannelNames.length,
                    itemBuilder: (context, index) {
                      final meetingData = meetingsWithChannelNames[index];
                      final meeting = meetingData['meeting'] as Meeting;
                      final channelName = meetingData['channelName'] as String;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.videocam_outlined,
                                color: Colors.blue),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  meeting.meetingTitle, // Tên cuộc họp
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2, // Giới hạn 2 dòng
                                  overflow: TextOverflow
                                      .ellipsis, // Thêm dấu "..." nếu quá dài
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('HH:mm').format(
                                        meeting.startTime), // Giờ bắt đầu
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.groups,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    channelName, // Tên nhóm
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // onTap: () {
                          //   // Xử lý khi nhấn vào cuộc họp
                          // },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
