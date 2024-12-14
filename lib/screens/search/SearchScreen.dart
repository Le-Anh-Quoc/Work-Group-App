// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/channel/channel_model.dart';
import 'package:ruprup/models/project/project_model.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/services/channel_service.dart';
import 'package:ruprup/services/project_service.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/search/ChannelWidget.dart';
import 'package:ruprup/widgets/search/PeopleWidget.dart';
import 'package:ruprup/widgets/search/ProjectWidget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchUserResults = [];
  List<Channel> _searchChannelResults = [];
  List<Project> _searchProjectResults = [];
  String _selectedCategory = 'people'; // Default selected category

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      switch (_selectedCategory) {
        case 'people':
          _searchPeople(searchText);
          break;
        case 'channel':
          _searchChannels(searchText);
          break;
        case 'project':
          _searchProjects(searchText);
          break;
      }
    } else {
      setState(() {
        _searchUserResults = [];
        _searchChannelResults = [];
        _searchProjectResults = [];
      });
    }
  }

  Future<void> _searchPeople(String query) async {
    final results = await UserService().searchUsers(query); // Tìm người
    setState(() {
      _searchUserResults = results;
    });
  }

  Future<void> _searchChannels(String query) async {
    // Gọi hàm tìm kiếm channels
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    final results = await ChannelService()
        .searchChannels(query, currentUser!.userId); // Tìm channels
    setState(() {
      _searchChannelResults = results;
    });
  }

  Future<void> _searchProjects(String query) async {
    // Gọi hàm tìm kiếm projects
    final results =
        await ProjectService().searchProjects(query); // Tìm projects
    setState(() {
      _searchProjectResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100], // Lighter grey background
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Search for people, projects, channels',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.search, color: Colors.blue,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                        color: Colors.blue, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  _buildCategoryChip('people'),
                  const SizedBox(width: 10),
                  _buildCategoryChip('channel'),
                  const SizedBox(width: 10),
                  _buildCategoryChip('project'),
                ],
              ),

              // Search Results
              if (_selectedCategory == 'people')
                Expanded(
                  child: _searchUserResults.isEmpty
                      ? _buildNoDataFound(Icons.person_outline, 'No people found.')
                      : ListView.builder(
                          itemCount: _searchUserResults.length,
                          itemBuilder: (context, index) {
                            UserModel user = _searchUserResults[index];
                            return PeopleWidget(people: user);
                          },
                        ),
                ),
              if (_selectedCategory == 'channel')
                Expanded(
                  child: _searchChannelResults.isEmpty
                      ? _buildNoDataFound(Icons.groups, 'No channels found.')
                      : ListView.builder(
                          itemCount: _searchChannelResults.length,
                          itemBuilder: (context, index) {
                            Channel channel = _searchChannelResults[index];
                            return ChannelWidget(channel: channel);
                          },
                        ),
                ),
              if (_selectedCategory == 'project')
                Expanded(
                  child: _searchProjectResults.isEmpty
                      ? _buildNoDataFound(Icons.dashboard_outlined, 'No projects found.')
                      : ListView.builder(
                          itemCount: _searchProjectResults.length,
                          itemBuilder: (context, index) {
                            Project project = _searchProjectResults[index];
                            return ProjectWidget(project: project);
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataFound(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        _onSearchTextChanged();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }
}
