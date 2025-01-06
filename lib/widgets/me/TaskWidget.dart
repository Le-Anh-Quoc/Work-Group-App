// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TaskIndivi extends StatelessWidget {
  final Color color;
  final String typeTask;
  final String numberTask;

  const TaskIndivi({
    super.key,
    required this.typeTask,
    required this.numberTask,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Tính toán màu sắc nhạt hơn từ màu chính
    Color backgroundColor = color.withOpacity(0.1); // Màu nền nhạt
    Color progressBackgroundColor = color.withOpacity(0.2); // Màu nền vòng tròn
    Color textColor = color.withOpacity(0.8); // Màu chữ chính

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor, // Sử dụng màu nền nhạt
        borderRadius: BorderRadius.circular(15.0), // Bo góc
      ),
      height: 200,
      width: 160,
      //height: 250, // Chiều rộng của widget
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // CircularPercentIndicator(
              //   radius: 40.0, // Kích thước vòng tròn
              //   lineWidth: 8.0, // Độ dày vòng tròn
              //   percent: 0.81, // Phần trăm
              //   center: Text(
              //     percentTask,
              //     style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //       fontSize: 16.0,
              //       color: textColor, // Màu chữ phần trăm
              //     ),
              //   ),
              //   progressColor: color, // Màu của vòng tròn
              //   backgroundColor:
              //       progressBackgroundColor, // Màu nền của vòng tròn
              // ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            typeTask,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: textColor, // Màu chữ loại task
            ),
          ),
          //SizedBox(height: 10.0),
          Text(
            "$numberTask task",
            style: TextStyle(
              fontSize: 16.0,
              color: color.withOpacity(0.6), // Màu chữ nhạt hơn
            ),
          ),
          // Align(
          //   alignment: Alignment.bottomRight,
          //   child: Container(
          //     padding: const EdgeInsets.all(8.0), // Điều chỉnh khoảng cách bên trong
          //     decoration: BoxDecoration(
          //       color: color, // Màu nền
          //       borderRadius: BorderRadius.circular(8.0), // Bo góc
          //     ),
          //     child: const Icon(
          //       Icons.arrow_forward,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
