// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:ruprup/services/user_service.dart';
// import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';
// import '../../screens/task/TaskDetailScreen.dart';
// //import 'package:slideable/Slideable.dart';

// class TodoWidget extends StatefulWidget {
//   const TodoWidget({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<TodoWidget> createState() => _TodoState();
// }

// class _TodoState extends State<TodoWidget> {
//   // This is used to monitor the item index in the list, and later used to closeup or leave open the slide.
//   int resetSlideIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     //var classList = _classList;
//     return Padding(
//       padding: const EdgeInsets.all(9.0),
//       child: ListView.separated(
//         itemCount: _classList.length,
//         itemBuilder: (context, index) {
//           Map<String, dynamic> _todoList = _classList[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => TaskDetailScreen(
//                     task: Task(
//                       id: _todoList["id"],
//                       name: _todoList["name"],
//                       description: _todoList["description"],
//                       assignedTo: _todoList["assignedTo"],
//                       dueDate: _todoList["createAt"],
//                       status: "In Progress",
//                     ),
//                   ),
//                 ),
//               );
//             },
//             onLongPressDown: (val) {
//               setState(() {
//                 resetSlideIndex = index;
//               });
//             },
//             // child: _listItem(
//             //   context: context,
//             //   todoList: _todoList,
//             //   index: index,
//             //   resetSlide: index == resetSlideIndex ? false : true,
//             // ),
//           );
//         },
//         separatorBuilder: (context, index) => const SizedBox(height: 20),
//       ),
//     );
//   }

//   // Slideable _listItem({
//   //   required BuildContext context,
//   //   required Map<String, dynamic> todoList,
//   //   required int index,
//   //   required bool resetSlide,
//   // }) {
//   //   return Slideable(
//   //     resetSlide: resetSlide,
//   //     key: ValueKey(todoList["id"]),
//   //     items: <ActionItems>[
//   //       ActionItems(
//   //         icon: const Icon(
//   //           Icons.done,
//   //           color: Colors.green,
//   //         ),
//   //         //onPress: () => _deleteUser(todoList["name"]),
//   //         onPress: () {},
//   //         backgroudColor: Colors.transparent,
//   //       ),
//   //     ],
//   //     child: Container(
//   //       padding: const EdgeInsets.all(15),
//   //       decoration: BoxDecoration(
//   //         color: Colors.white,
//   //         border: Border.all(
//   //           width: 2,
//   //           color: Colors.black87,
//   //         ),
//   //         borderRadius: BorderRadius.circular(10),
//   //       ),
//   //       child: Row(
//   //         crossAxisAlignment: CrossAxisAlignment.center,
//   //         children: [
//   //           Expanded(
//   //             child: Column(
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: [
//   //                 Text(
//   //                   todoList["name"],
//   //                   style: TextStyle(
//   //                     color: Colors.black,
//   //                     fontSize: 20,
//   //                     fontWeight: FontWeight.w900,
//   //                   ),
//   //                 ),
//   //                 const SizedBox(height: 10),
//   //                 Padding(
//   //                   padding: const EdgeInsets.only(right: 13),
//   //                   child: Row(
//   //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                     children: [
//   //                       Row(children: [
//   //                         Icon(Icons.calendar_month),
//   //                         SizedBox(width: 5),
//   //                         Text('8 Oct 2022'),
//   //                       ]),
//   //                       Text(
//   //                         todoList["id"],
//   //                         style: const TextStyle(
//   //                           fontWeight: FontWeight.w500,
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //           InitialsAvatar(name: todoList["assignedTo"]),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // _deleteUser(user) {
//   //   ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//   //     SnackBar(
//   //       content: Text("$user, will be deleted."),
//   //       backgroundColor: Colors.grey[450],
//   //     ),
//   //   );
//   // }

//   final List<Map<String, dynamic>> _classList = [
//     {
//       "name": "Task 1 - Display Login",
//       "description": "Implement loginaaaaaaa screen with authentication",
//       "id": "COF-1",
//       "assignedTo": "Bùi Trọng Đại",
//       "createAt": "2024-10-1",
//     },
//     {
//       "name": "Task 2 - Display Logout",
//       "description": "Implement logout functionality",
//       "id": "COF-2",
//       "assignedTo": "Nguyễn Duy Tân",
//       "createAt": "2024-10-1",
//     },
//     {
//       "name": "Task 2 - Display Logout",
//       "description": "Implement logout functionality",
//       "id": "COF-2",
//       "assignedTo": "Nguyễn Duy Tân",
//       "createAt": "2024-10-1",
//     },
//     {
//       "name": "Task 9- Display Logout",
//       "description": "Implement logout functionality",
//       "id": "COF-3",
//       "assignedTo": "Phạm Phúc",
//       "createAt": "2024-10-1",
//     },
//     {
//       "name": "Task 5 -  Logout",
//       "description": "Implement logout functionality",
//       "id": "COF-4",
//       "assignedTo": "Văn Thịnh",
//       "createAt": "2024-10-1",
//     },
//     // Add more tasks here
//   ];
// }

// // class Task {
// //   final String id;
// //   final String name;
// //   final String description;
// //   final String assignedTo;
// //   final String dueDate;
// //   final String status;

// ignore_for_file: file_names

// //   Task({
// //     required this.id,
// //     required this.name,
// //     required this.description,
// //     required this.assignedTo,
// //     required this.dueDate,
// //     required this.status,
// //   });
// // }
