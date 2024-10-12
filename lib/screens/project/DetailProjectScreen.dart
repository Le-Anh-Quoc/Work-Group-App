import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/screens/MainScreen.dart';
import 'package:ruprup/screens/project/ProjectScreen.dart';
import 'package:ruprup/widgets/project/ProjectWidget.dart';
import 'package:ruprup/widgets/task/BoardTypeTaskWidget.dart';
import 'package:ruprup/widgets/task/TypeTaskWidget.dart';

class DetailProjectScreen extends StatefulWidget {
  final Project project;
  const DetailProjectScreen({super.key, required this.project});

  @override
  State<DetailProjectScreen> createState() => _DetailProjectScreenState();
}

class _DetailProjectScreenState extends State<DetailProjectScreen> {
  @override
  Widget build(BuildContext context) {
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
                    builder: (_) => MainScreen(selectedIndex: 3),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back_ios_new)),
          title: const Center(
              child: Text(
            'Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          )),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Hero(
                tag: 'project-${widget.project.projectId}',
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
                        offset:
                            const Offset(0, 4), // Đặt bóng nhẹ nhàng phía dưới
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
                            Text(widget.project.projectName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24)),
                            // Text(widget.project.description,
                            //     style: TextStyle(
                            //         color: Colors.grey, fontSize: 16)),
                            const Text('Team',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            Container(
                              height: 30,
                              child: Stack(
                                children: List.generate(widget.project.memberIds.length, (index) {
                                  return Positioned(
                                    left: index *
                                        18, // Điều chỉnh khoảng cách giữa các avatar
                                    child: CircleAvatar(
                                      radius: 15, // Bán kính avatar
                                      backgroundImage: NetworkImage(
                                          'https://randomuser.me/api/portraits/women/$index.jpg'),
                                    ),
                                  );
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
                                        DateFormat('MMM d, y').format(widget.project.startDate),
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
                                        '${widget.project.getTotalTask()} Tasks',
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
                            percent: widget.project.getTotalTask() > 0 ? widget.project.done / widget.project.getTotalTask() : 0,
                            center: Text(
                              widget.project.getTotalTask() > 0 ? '${((widget.project.done / widget.project.getTotalTask()) * 100).toStringAsFixed(0)}%' : '0%',
                              style: TextStyle(
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
              SizedBox(height: 10),
              // Expanded(
              //   child: GridView.count(
              //     crossAxisCount: 2, // 2 cột
              //     // crossAxisSpacing: 2.0, // Khoảng cách ngang giữa các widget
              //     // mainAxisSpacing: 2.0, // Khoảng cách dọc giữa các widget
              //     childAspectRatio: 1.3,
              //     children: [
              //       TypeTaskWidget(
              //           total: widget.project.toDo,
              //           typeTask: 'To do',
              //           color: Colors.orangeAccent,
              //           icon: Icons.task),
              //       TypeTaskWidget(
              //           total: widget.project.inProgress,
              //           typeTask: 'In progress',
              //           color: Colors.blueAccent,
              //           icon: Icons.timeline),
              //       TypeTaskWidget(
              //           total: widget.project.inReview,
              //           typeTask: 'In review',
              //           color: Colors.redAccent,
              //           icon: Icons.visibility),
              //       TypeTaskWidget(
              //           total: widget.project.done,
              //           typeTask: 'Completed',
              //           color: Colors.greenAccent,
              //           icon: Icons.check_box_rounded),
              //     ],
              //   ),
              // ),
              BoardTypeTaskWidget(project: widget.project)
              // Center(
              //   child: Container(
              //     decoration: BoxDecoration(
              //         color: Colors.white,
              //         border: Border.all(color: Colors.black),
              //         borderRadius: BorderRadius.circular(15)),
              //     child: Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Column(
              //         children: [
              //           Text('Total task activity'),
              //           Text(
              //             '125 Task',
              //             style: TextStyle(
              //                 fontWeight: FontWeight.bold, fontSize: 22),
              //           )
              //         ],
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
