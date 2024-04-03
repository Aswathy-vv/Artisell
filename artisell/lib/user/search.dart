import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class search extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}
class _SearchScreenState extends State<search> {
  late TextEditingController _searchController;
  late Query _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchQuery = FirebaseFirestore.instance.collection('search');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor:Color(0xffd2cdbf),
      appBar: AppBar(backgroundColor:Color(0xffd2cdbf),
        title: TextField(
          onChanged: (value) {
            _onSearchTextChanged(_capitalizeFirstWord(value));
          },
          controller: _searchController,

          decoration: InputDecoration(
            hintText: 'Search...',
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _searchQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No results found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot admin = snapshot.data!.docs[index];
              Map<String, dynamic> data = admin.data() as Map<String, dynamic>;

              return GestureDetector( onTap: (){
                Navigator.pushNamed(context,'show',arguments: {
                  "url":admin["image"],
                  "feature":admin["feature"],
                  "name":admin["itemname"],
                  "prices":admin["price"],

                });
              },
                child: ListTile(
                  title: Text(data['itemname']),
                  // Other widgets to display additional information
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onSearchTextChanged(String newText) {
    setState(() {
      _searchQuery = FirebaseFirestore.instance.collection('search')
          .where('itemname', isGreaterThanOrEqualTo: newText)
          .where('itemname', isLessThan: newText + 'z');
    });
  }
  String _capitalizeFirstWord(String text) {
    if (text.isEmpty) {
      return text; // Return empty string if no text is entered
    }
    // Capitalize first letter of the first word
    return text[0].toUpperCase() + text.substring(1);
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
