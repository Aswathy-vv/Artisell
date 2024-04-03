import 'package:artisell/admin/New.dart';
import 'package:artisell/user/home.dart';
import 'package:artisell/user/categories.dart';
import 'package:artisell/user/mycart.dart';
import 'package:artisell/user/profile.dart';
import 'package:artisell/user/search.dart';
import 'package:artisell/user/wishlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class homepage extends StatefulWidget {
  const homepage({super.key, required this.userid});

  final String userid;

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  int current_index = 0;

  List pages = [Home(), categories(), wishlist(), Account()];
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xffd2cdbf),
        body: pages[current_index],
        bottomNavigationBar: Container(
          height: 70,
          decoration: BoxDecoration(
color: Color(0xffd2cdbf),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10))),
          child: GNav(
              padding: EdgeInsetsDirectional.all(10),
              onTabChange: (index) => setState(() {
                    current_index = index;
                  }),
              tabs: [
                GButton(iconActiveColor: Color(0xff6c1812),
                  padding: EdgeInsets.all(10),
                  backgroundColor: Color(0xffffffff),
                  icon: Icons.home,iconColor: Color(0xff141a15),

                ),
                GButton(iconActiveColor: Color(0xff6c1812),
                  padding: EdgeInsets.all(10),
                  backgroundColor: Color(0xffffffff),
                  icon: Icons.category,iconColor:  Color(0xff141a15),
                ),
                GButton(iconActiveColor: Color(0xff6c1812),
                  padding: EdgeInsets.all(10),
                  backgroundColor: Color(0xffffffff),
                  icon: Icons.favorite,iconColor:  Color(0xff141a15),

                ),
                GButton(iconActiveColor: Color(0xff6c1812),
                  padding: EdgeInsets.all(10),
                  backgroundColor: Color(0xffffffff),
                  icon: Icons.person,iconColor: Color(0xff141a15),

                ),
              ]),
        ));
  }
}
