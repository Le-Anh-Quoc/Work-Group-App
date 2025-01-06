// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/providers/activity_provider.dart';
import 'package:ruprup/widgets/project/ActivityWidget.dart';
import 'package:table_calendar/table_calendar.dart';

class ActivityProjectScreen extends StatefulWidget {
  final String projectId;
  const ActivityProjectScreen({super.key, required this.projectId});

  @override
  State<ActivityProjectScreen> createState() => _ActivityProjectScreenState();
}

class _ActivityProjectScreenState extends State<ActivityProjectScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchActivitiesForDate(_selectedDay);
  }

  void _fetchActivitiesForDate(DateTime date) {
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    activityProvider.fetchActivitiesbyDate(widget.projectId, date);
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              activityProvider.clearActivitiesbyDate();
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue)),
        backgroundColor: Colors.white,
        title: const Text('Activities',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 24)),
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
                    blurRadius: 10,
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
                    _fetchActivitiesForDate(_selectedDay);
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
                      border: Border.all(width: 1, color: Colors.blue)),
                  todayTextStyle: const TextStyle(color: Colors.blue),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (activityProvider.activityByDate.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off, // Icon đại diện
                        size: 80, // Kích thước lớn hơn để thu hút sự chú ý
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16), // Khoảng cách giữa icon và văn bản
                      Text(
                        'No activities for this day!',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w500, // Văn bản đậm hơn một chút
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: activityProvider.activityByDate.length,
                itemBuilder: (context, index) {
                  final activity = activityProvider.activityByDate[index];
                  return ActivityWidget(actLog: activity);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
