// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project/project_model.dart';
import 'package:ruprup/screens/project/DetailProjectScreen.dart';

class ChildProjectWidget extends StatelessWidget {
  final Project project;
  const ChildProjectWidget({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          Provider.of<Project>(context, listen: false)
              .setCurrentProject(project);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailProjectScreen(project: project),
            ),
          );
        },
        child: Container(
                //height: 120,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.withOpacity(0.3), // Màu sắc nhẹ nhàng hơn
                  //     spreadRadius: 2, // Tăng độ lan tỏa
                  //     blurRadius: 15, // Tăng độ mờ
                  //     offset: const Offset(0, 4), // Đặt bóng nhẹ nhàng phía dưới
                  //   ),
                  // ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 140,
                            child: Text(project.projectName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                        maxLines: 2,),
                          ),
                          Text(
                            '${project.getTotalTask()} Tasks',
                            style: const TextStyle(
                              color: Colors
                                  .grey, // Set the text color to grey
                              fontSize: 16, // Set text size
                            ),
                          )
                        ],
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   right: 0,
                      //   child: CircularPercentIndicator(
                      //     radius: 30,
                      //     lineWidth: 8.0,
                      //     percent: project.getTotalTask() > 0
                      //         ? project.done / project.getTotalTask()
                      //         : 0,
                      //     center: Text(
                      //       project.getTotalTask() > 0
                      //           ? '${((project.done / project.getTotalTask()) * 100).toStringAsFixed(0)}%'
                      //           : '0%',
                      //       style: const TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 15.0,
                      //         color: Colors.grey,
                      //       ),
                      //     ),
                      //     progressColor: Colors.blue,
                      //     backgroundColor: Colors.grey.shade200,
                      //     circularStrokeCap:
                      //         CircularStrokeCap.round, // Đảm bảo viền tròn
                      //   ),
                      // ),
                      if (currentUserId == project.ownerId)
                        const Positioned(
                            top: 0, right: 0, child: Icon(Icons.star, size: 20, color: Colors.amber))
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}