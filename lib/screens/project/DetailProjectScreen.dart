// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/activityProject_model.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/screens/MainScreen.dart';
import 'package:ruprup/screens/project/ActivityScreen.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';
import 'package:ruprup/widgets/project/ActivityWidget.dart';
import 'package:ruprup/widgets/task/BoardTypeTaskWidget.dart';

class DetailProjectScreen extends StatefulWidget {
  final Project? project;
  const DetailProjectScreen({super.key, required this.project});

  @override
  State<DetailProjectScreen> createState() => _DetailProjectScreenState();
}

class _DetailProjectScreenState extends State<DetailProjectScreen> {
  @override
  void initState() {
    super.initState();
    final activityProvider = Provider.of<ActivityLog>(context, listen: false);
    activityProvider.fetchRecentActivities(widget.project!.projectId);
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityLog>(context);
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(selectedIndex: 1),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back_ios_new)),
          title: const Text(
                      'Overview',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
          centerTitle: true,
          actions: [
            if (currentUserId == widget.project!.ownerId)
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Hero(
                  tag: 'project-${widget.project!.projectId}',
                  flightShuttleBuilder: (flightContext, animation, direction,
                      fromContext, toContext) {
                    return FadeTransition(
                      opacity: animation,
                      child: fromContext.widget,
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .withOpacity(0.3), // Màu sắc nhẹ nhàng hơn
                          spreadRadius: 2, // Tăng độ lan tỏa
                          blurRadius: 15, // Tăng độ mờ
                          offset: const Offset(
                              0, 4), // Đặt bóng nhẹ nhàng phía dưới
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(widget.project!.projectName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24)),
                              // Text(widget.project.description,
                              //     style: TextStyle(
                              //         color: Colors.grey, fontSize: 16)),
                              const Text('Team',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 30,
                                child: Stack(
                                  children: List.generate(
                                      widget.project!.memberIds.length,
                                      (index) {
                                    final uid =
                                        widget.project!.memberIds[index];
                                    return Positioned(
                                        left: index *
                                            18, // Điều chỉnh khoảng cách giữa các avatar
                                        // child: CircleAvatar(
                                        //   radius: 15, // Bán kính avatar
                                        //   backgroundImage: NetworkImage(
                                        //       'https://randomuser.me/api/portraits/women/$index.jpg'),
                                        // ),
                                        child: InitialsAvatar(
                                            name: UserService()
                                                .getFullNameByUid(uid),
                                            size: 25));
                                  }),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 24.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_month,
                                          color: Colors
                                              .grey, // Set the icon color to grey
                                          size: 16, // Set icon size
                                        ),
                                        const SizedBox(
                                            width:
                                                5), // Add spacing between icon and text
                                        Text(
                                          DateFormat('MMM d, y').format(
                                              widget.project!.startDate),
                                          style: const TextStyle(
                                            color: Colors
                                                .grey, // Set the text color to grey
                                            fontSize: 16, // Set text size
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_box_rounded,
                                          color: Colors
                                              .grey, // Set the icon color to grey
                                          size: 16, // Set icon size
                                        ),
                                        const SizedBox(
                                            width:
                                                5), // Add spacing between icon and text
                                        Text(
                                          '${widget.project!.getTotalTask()} Tasks',
                                          style: const TextStyle(
                                            color: Colors
                                                .grey, // Set the text color to grey
                                            fontSize: 16, // Set text size
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: CircularPercentIndicator(
                              radius: 50,
                              lineWidth: 14.0,
                              percent: widget.project!.getTotalTask() > 0
                                  ? widget.project!.done /
                                      widget.project!.getTotalTask()
                                  : 0,
                              center: Text(
                                widget.project!.getTotalTask() > 0
                                    ? '${((widget.project!.done / widget.project!.getTotalTask()) * 100).toStringAsFixed(0)}%'
                                    : '0%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  color: Colors.grey,
                                ),
                              ),
                              progressColor: Colors.blue,
                              backgroundColor: Colors.grey.shade200,
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                BoardTypeTaskWidget(project: widget.project),
                //const SizedBox(height: 10),
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Activity',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            TextButton(
                              child: const Text(
                                'See all',
                                style: TextStyle(color: Colors.grey),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ActivityScreen(
                                        projectId: widget.project!.projectId),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (activityProvider.activity.isEmpty)
                          Container(
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: const Center(
                              child: Text(
                                'Currently, don\'t have any activity',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: activityProvider.activity.length,
                            itemBuilder: (context, index) {
                              final activity = activityProvider.activity[index];
                              return ActivityWidget(actLog: activity);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
