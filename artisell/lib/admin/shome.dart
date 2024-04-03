
import 'package:artisell/admin/New.dart';
import 'package:artisell/admin/adminchat.dart';
import 'package:artisell/admin/mydelivery.dart';
import 'package:artisell/admin/painting.dart';
import 'package:artisell/admin/product.dart';
import 'package:artisell/admin/stockupdate.dart';
import 'package:artisell/user/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:artisell/admin/all.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../user/chat.dart';
import 'adfashion.dart';
import 'chatscreen.dart';

class Shome extends StatefulWidget {
  @override
  State<Shome> createState() => _ShomeState();
}

class _ShomeState extends State<Shome> {

  @override
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Clear user ID from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      // Navigate back to SignIn screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
    } catch (e) {
      print("Error signing out: $e");
      // Handle sign-out error
    }
  }

  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('Add items'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Admin page',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  // Handle home tap
                  Navigator.pop(context); // Close the drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.delivery_dining),
                title: Text('My delivery'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Order()));
                  // Handle settings tap
                 // Close the drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('My products'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>product()));
                  // Handle settings tap
                  // Close the drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.production_quantity_limits_sharp),
                title: Text('My stock'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>StockUpdatesPage()));
                  // Handle settings tap
                  // Close the drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('chatlogin'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Chat()));
                  // Handle settings tap
                  // Close the drawer
                },
              ),ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sign Out'),
                onTap: _signOut,
              ),

              // Add more ListTile widgets for additional menu items
            ],
          ),
        ),
        body:DefaultTabController(
          length: 4, // Number of tabs
          child: Column(
            children: <Widget>[
              TabBar(
                  indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 4, color: Colors.orange)),
                  padding: EdgeInsets.only(left: 0, right: 0),
                  isScrollable: true,
                  tabs: [
                    Tab(text: " homedecor "),
                    Tab(text: "fashion"),
                    Tab(text: "paintings"),
                    Tab(text: "New"),
                  ]),
              Expanded(
                  child: TabBarView(
                    children: [
                     All(),Fashion(),Painting(),New()
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.all(10.0),
              ),
            ],
          ),
        ),
      // Show a bottom sheet with options to pick an image
        );
  }
}

