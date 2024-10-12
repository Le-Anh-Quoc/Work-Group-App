import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/screens/project/DetailProjectScreen.dart';
//import 'package:ruprup/services/project_service.dart';

class ProjectWidget extends StatelessWidget {
  final Project project;
  //final ProjectService _projectService = ProjectService();
  ProjectWidget({super.key, required this.project}) {
    debugPrint('Project ID: ${project.projectId}');
    debugPrint('Project Name: ${project.projectName}');
    debugPrint('To Do: ${project.toDo}');
    debugPrint('Done: ${project.done}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      // child: FutureBuilder<Project?>(
      //     future: _projectService.getProject(idProject),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return Center(child: CircularProgressIndicator());
      //       } else if (snapshot.hasError) {
      //         return Center(child: Text('Có lỗi xảy ra'));
      //       } else if (!snapshot.hasData || snapshot.data == null) {
      //         return Center(child: Text('Không tìm thấy dự án'));
      //       }

      //       Project project = snapshot.data!; // Lấy dự án từ snapshot

      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailProjectScreen(project: project),
            ),
          );
        },
        child: Hero(
          tag: 'project-${project.projectId}',
          flightShuttleBuilder:
              (flightContext, animation, direction, fromContext, toContext) {
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
                  color: Colors.grey.withOpacity(0.3), // Màu sắc nhẹ nhàng hơn
                  spreadRadius: 2, // Tăng độ lan tỏa
                  blurRadius: 15, // Tăng độ mờ
                  offset: const Offset(0, 4), // Đặt bóng nhẹ nhàng phía dưới
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
                      Text(project.projectName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.blueAccent)),
                      // Text(project.description,
                      //     style: const TextStyle(
                      //         color: Colors.grey, fontSize: 16)),
                      const Text('Team',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Container(
                        height: 30,
                        child: Stack(
                          children:
                              List.generate(project.memberIds.length, (index) {
                            return Positioned(
                              left: index *
                                  25, // Điều chỉnh khoảng cách giữa các avatar
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
                        padding: const EdgeInsets.only(right: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color:
                                      Colors.grey, // Set the icon color to grey
                                  size: 16, // Set icon size
                                ),
                                const SizedBox(
                                    width:
                                        5), // Add spacing between icon and text
                                Text(
                                  DateFormat('MMM d, y')
                                      .format(project.startDate),
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
                                  color:
                                      Colors.grey, // Set the icon color to grey
                                  size: 16, // Set icon size
                                ),
                                const SizedBox(
                                    width:
                                        5), // Add spacing between icon and text
                                Text(
                                  '${project.getTotalTask()} Tasks',
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
                      percent: project.getTotalTask() > 0
                          ? project.done / project.getTotalTask()
                          : 0,
                      center: Text(
                        project.getTotalTask() > 0
                            ? '${((project.done / project.getTotalTask()) * 100).toStringAsFixed(0)}%'
                            : '0%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          color: Colors.grey,
                        ),
                      ),
                      progressColor: Colors.blue,
                      backgroundColor: Colors.grey.shade200,
                      circularStrokeCap:
                          CircularStrokeCap.round, // Đảm bảo viền tròn
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
