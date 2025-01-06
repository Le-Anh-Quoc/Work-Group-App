// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project/project_model.dart';
import 'package:ruprup/providers/activity_provider.dart';
import 'package:ruprup/screens/MainScreen.dart';
import 'package:ruprup/screens/project/ActivityProjectScreen.dart';
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
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    activityProvider.fetchRecentActivities(widget.project!.projectId);
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
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
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue)),
          title: const Text(
            'Overview',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blue),
          ),
          centerTitle: true,
          // actions: [
          //   if (currentUserId == widget.project!.ownerId)
          //     IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.blue))
          // ],
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
                        border: Border.all(width: 1, color: Colors.blue)),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Team',
                                      style: TextStyle(
                                          color: Colors.grey,
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
                                                25, // Điều chỉnh khoảng cách giữa các avatar
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
                                ],
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
                          if (currentUserId == widget.project!.ownerId)
                            const Positioned(
                                top: 0,
                                right: 0,
                                child: Icon(Icons.star,
                                    size: 20, color: Colors.amber))
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
                                    builder: (_) => ActivityProjectScreen(
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
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history_toggle_off, // Icon biểu cảm
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No activity found!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start by creating or joining an activity.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
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
