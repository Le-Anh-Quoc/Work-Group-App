import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/screens/project/DetailProjectScreen.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';
//import 'package:ruprup/services/project_service.dart';

class ProjectWidget extends StatelessWidget {
  final Project project;
  const ProjectWidget({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Provider.of<Project>(context, listen: false).setCurrentProject(project);
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(project.projectName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.black)),
                          // IconButton(
                          //   onPressed: () async {
                          //     // Hiển thị hộp thoại xác nhận
                          //     bool? confirm = await showDialog<bool>(
                          //       context: context,
                          //       builder: (BuildContext context) {
                          //         return AlertDialog(
                          //           backgroundColor: Colors.white,
                          //           title: const Text('Delete Project'),
                          //           content: const Text('Are you sure you want to delete this project?'),
                          //           actions: <Widget>[
                          //             TextButton(
                          //               child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
                          //               onPressed: () {
                          //                 Navigator.of(context).pop(false); // Trả về false khi hủy
                          //               },
                          //             ),
                          //             TextButton(
                          //               child: const Text('Delete', style: TextStyle(color: Colors.blue)),
                          //               onPressed: () {
                          //                 Navigator.of(context).pop(true); // Trả về true khi xác nhận
                          //               },
                          //             ),
                          //           ],
                          //         );
                          //       },
                          //     );

                          //     // Nếu người dùng xác nhận, gọi phương thức xóa
                          //     if (confirm == true) {
                          //       await Provider.of<Project>(context, listen: false).deleteProject(project.projectId);
                          //     }
                          //   },
                          //   icon: const Icon(Icons.delete),
                          //   color: Colors.red, // Màu đỏ cho icon xóa
                          // ),
                        ],
                      ),
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
                                final uid = project.memberIds[index];
                            return Positioned(
                              left: index *
                                  25, // Điều chỉnh khoảng cách giữa các avatar
                              // child: CircleAvatar(
                              //   radius: 15, // Bán kính avatar
                              //   backgroundImage: NetworkImage(
                              //       'https://randomuser.me/api/portraits/women/$index.jpg'),
                              // ),
                              child: InitialsAvatar(name: UserService().getFullNameByUid(uid), size: 25)
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
                    top: 10,
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
