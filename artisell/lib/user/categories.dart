import 'dart:ui';
import 'package:artisell/user/paint.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'homedecor.dart';
import 'fashion.dart';

class categories extends StatefulWidget {
  const categories({super.key});

  @override
  State<categories> createState() => _categoriesState();
}

class _categoriesState extends State<categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: Color(0xff413821),
      appBar: AppBar(automaticallyImplyLeading: false,
          backgroundColor: Color(0xff413821),
          title: Center(
              child: Text(
            "Categories",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ))),
      body: DefaultTabController(
        length: 3, // Number of tabs
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ButtonsTabBar(

                decoration: BoxDecoration(color: Color(0xff6c1812),shape: BoxShape.circle),
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),buttonMargin: EdgeInsets.only(bottom: 10,left: 20,right: 40),
                tabs: [
                  Tab(text: "  homedecor    "),
                  Tab(text: "   fashion     "),
                  Tab(text: "   painting    "),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [homedecor(), fashionn(), Paint()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
