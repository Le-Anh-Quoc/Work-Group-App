import 'package:flutter/material.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/search/PeopleWidget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService(); // Instance of UserService
  List<UserModel> _searchResults = [];
  bool _isLoading = false;

  // void _searchUser(String email) async {
  //   String Querry= _searchController.text.trim();
  // if (Querry.isEmpty) return;

  //   setState(() {
  //     _isLoading =true;
  //   });
  //   try {
  //   List<UserModel> results = await _userService.searchUsers(Querry);

  //   setState(() {
  //     _searchResults = results;
  //   });

  //   if (results.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Không tìm thấy người dùng!')),
  //     );
  //   }
  // } catch (e) {
  //   // Xử lý lỗi khi tìm kiếm thất bại
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Đã xảy ra lỗi: $e')),
  //   );
  // } finally {
  //   setState(() {
  //     _isLoading = false; // Tắt trạng thái loading
  //   });
  // }

  // }
  void _searchUser(String email) async {
    if (_searchController.text.isEmpty) return;

    List<UserModel> results =
        await _userService.searchUsers(_searchController.text);

    setState(() {
      _searchResults = results;
    });
  }
  // Đợi người dùng ngừng nhập khoảng 1s rồi mới thực hiện tìm kiếm
  // void _onSearchChanged() {
  //   if (_searchController.text.isEmpty) {
  //     setState(() {
  //       _searchResults.clear();
  //     });
  //     return;
  //   }

  //   Future.delayed(const Duration(seconds: 1), () async {
  //     if (_searchController.text.isNotEmpty) {
  //       setState(() {
  //         _isLoading = true;
  //       });

  //       List<UserModel> results =
  //           await _userService.searchUsers(_searchController.text.trim());

  //       setState(() {
  //         _searchResults = results;
  //         _isLoading = false;
  //       });
  //     }
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _searchController.addListener(_onSearchChanged);
  // }

  // @override
  // void dispose() {
  //   _searchController.removeListener(_onSearchChanged);
  //   _searchController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            // crossAxisAlignment:
            //     CrossAxisAlignment.start, // Align children to the start
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100], // Lighter grey background
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Search',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.blueAccent),
                    onPressed: () => _searchUser(_searchController.text.trim()),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2), // Focused border color
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Search Results
              Expanded(
                child: _searchResults.isEmpty
                    ? const Center(
                        child: Text('No users found.',
                            style: TextStyle(fontSize: 16, color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          UserModel user = _searchResults[index];
                          return PeopleWidget(
                              targetUserId: user.userId);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
