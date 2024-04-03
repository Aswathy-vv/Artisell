import 'package:artisell/user/order.dart';
import 'package:artisell/user/savedaddresss.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat.dart';
class Account extends StatelessWidget {
  Account({super.key});

  String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  Future<void> signOut(BuildContext context) async {
    try {
      // Optionally, clear the stored user ID in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      // Sign out the user after deleting the account
      await FirebaseAuth.instance.signOut();

      Navigator.pushNamed(context, 'signin'); // Navigate to sign-in screen

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        content: Text("Successfully signed out"),
      ));

      // Navigate to the 'signin' screen
      Navigator.pushNamed(context, 'signin');
    } catch (e) {
      print(e);
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        content: Text("Error signing out. Please try again."),
      ));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xffd2cdbf),
      appBar: AppBar(automaticallyImplyLeading: false,
        backgroundColor: Color(0xff413821),
        title: Center(child: Text("My Profile",style: TextStyle(color: Colors.white),)),
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 48),
            height: 680,
            decoration: BoxDecoration(
              color:  Color(0xffd2cdbf),
              borderRadius: BorderRadius.circular(16.0),),),
          Align(alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(backgroundColor: Colors.white, radius: 70,
                child: CircleAvatar(
                  backgroundColor: Color(0xff6c1812),
                  radius: 67,
                  child: Icon(Icons.person, size: 90,
                      color: Color.fromARGB(255, 255, 255, 255), ),),
              ),
            ),),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                ),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),

                buildListTile(context, "Chat", chat(), Icons.chat),
                SizedBox(
                  height: 30,
                ),
                buildListTile(context, "myorder", Myorder(), Icons.gif_box),
                SizedBox(
                  height: 30,
                ),
                buildListTile(context, "savedaddress", savedAddress(),
                    CupertinoIcons.location_solid),
                SizedBox(
                  height: 50,
                ),
                // buildListTile(context, "saved address", )
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff6c1812),),
                  onPressed: () {
                    signOut(context);
                  },
                  child:
                  Text("Sign Out", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget buildListTile(BuildContext context, String title, Widget page,
      IconData icon) {
    return GestureDetector(onTap: (){
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page));
    },
      child: ListTile(
        title: Text(title),
        trailing: Icon(
         Icons.arrow_forward_ios, color: Colors.black),
        leading: Container(
          child: Icon(icon, color: Colors.white),
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Color(0xff6c1812),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
