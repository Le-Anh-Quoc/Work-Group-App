// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/providers/activity_provider.dart';
import 'package:ruprup/providers/project_provider.dart';
import 'package:ruprup/providers/task_provider.dart';
import 'package:ruprup/widgets/project/ActivityWidget.dart';
import 'package:table_calendar/table_calendar.dart';

class ActivityTask extends StatefulWidget {
  final String currentProject;
  final String currentTask;
  const ActivityTask({super.key, required this.currentProject, required this.currentTask});

  @override
  State<ActivityTask> createState() => _ActivityTaskState();
}

class _ActivityTaskState extends State<ActivityTask> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchActivitiesForTaskandDate(widget.currentProject, widget.currentTask, _selectedDay);
  }

  void _fetchActivitiesForTaskandDate(String projectId, String taskId, DateTime date) {
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    
    activityProvider.fetchActivitiesbyTaskandDate(projectId, taskId, _selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final currentProject = Provider.of<ProjectProvider>(context, listen: false).currentProject;
    final currentTask = Provider.of<TaskProvider>(context, listen: false).selectedTask;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      width: double.maxFinite,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Activities',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue),
          ),
          const SizedBox(height: 10),
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
                  activityProvider.fetchActivitiesbyTaskandDate(widget.currentProject, widget.currentTask, _selectedDay);
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
          if (activityProvider.activityByTaskandDate.isEmpty)
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
              itemCount: activityProvider.activityByTaskandDate.length,
              itemBuilder: (context, index) {
                final activity = activityProvider.activityByTaskandDate[index];
                return ActivityWidget(actLog: activity);
              },
            ),
          ),
        ],
      ),
    );
  }
}