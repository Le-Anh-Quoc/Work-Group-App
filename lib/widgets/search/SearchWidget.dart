import 'package:flutter/material.dart';

class CustomSearchField extends StatefulWidget {
  @override
  _CustomSearchFieldState createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55, // Set the height of the TextField
      decoration: BoxDecoration(
        color: Colors.blue[50], // Light blue background
        borderRadius: BorderRadius.circular(8), // Optional: rounded corners
      ),
      child: TextField(
        //controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100], // Lighter grey background
          //labelStyle: const TextStyle(color: Colors.red),
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.blueAccent),
            onPressed: () => {},
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Colors.blueAccent, width: 2), // Focused border color
          ),
        ),
      ),
    );
  }
}
