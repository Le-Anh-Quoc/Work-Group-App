// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/activityProject_model.dart';
import 'package:ruprup/widgets/project/ActivityWidget.dart';

class ActivityScreen extends StatefulWidget {
  final String projectId;
  const ActivityScreen({super.key, required this.projectId});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  DateTime _selectedDate =
      DateTime.now(); // Ngày được chọn mặc định là ngày hôm nay
  List<DateTime> _weekDays = [];

  @override
  void initState() {
    super.initState();
    _setCurrentWeek(); // Thiết lập tuần hiện tại dựa trên ngày hôm nay
    _fetchActivitiesForDate(_selectedDate);
  }

  void _setCurrentWeek() {
    DateTime monday =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

    // Tạo danh sách các ngày trong tuần (thứ 2 đến chủ nhật)
    _weekDays = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  void _fetchActivitiesForDate(DateTime date) {
    final activityProvider = Provider.of<ActivityLog>(context, listen: false);
    activityProvider.fetchActivitiesbyDate(widget.projectId, date);
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _fetchActivitiesForDate(_selectedDate);
    });
  }

  List<Widget> _buildWeekdayButtons() {
    return _weekDays.map((date) {
      final isSelected =
          _selectedDate.isAtSameMomentAs(date); // Kiểm tra ngày được chọn
      return GestureDetector(
        onTap: () => _onDaySelected(date),
        child: Container(
          //padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            //color: isSelected ? Colors.blue : Colors.grey[300],
          ),
          child: Column(
            children: [
              Text(
                DateFormat.E().format(date), // Hiển thị tên ngày (Mon, Tue,...)
                style:
                    const TextStyle(color: Colors.grey),
              ),
              Container(
                width: 40.0, // Chiều rộng của hình tròn
                height: 40.0, // Chiều cao của hình tròn
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue
                      : Colors.transparent, // Màu nền tùy thuộc vào trạng thái
                  shape: BoxShape.circle, // Tạo hình tròn
                ),
                alignment: Alignment.center,
                child: Text(
                  date.day.toString(), // Hiển thị ngày trong tháng
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityLog>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Activities',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildWeekdayButtons(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (activityProvider.activityByDate.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'This day, don\'t have any activity',
                    style: TextStyle(color: Colors.grey),
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
