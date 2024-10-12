import 'package:flutter/material.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/person_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService(); // Instance of UserService
  List<Map<String, dynamic>> _searchResults = [];

  void _searchUser(String email) async {
    if (email.isEmpty) return;

    List<Map<String, dynamic>> results = await _userService.searchUserByEmail(email);

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
          children: [
            const SizedBox(height: 50),
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
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 2), // Focused border color
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search Results
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(child: Text('No users found.', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          elevation: 2, // Shadow effect for cards
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded corners for the card
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: PersonTile(
                              name: _searchResults[index]['fullname'],
                              targetUserId: _searchResults[index]['uid'],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
