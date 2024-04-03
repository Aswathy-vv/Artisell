import 'dart:ui';

import 'package:artisell/user/homedecor.dart';
import 'package:artisell/user/fashion.dart';
import 'package:artisell/user/mycart.dart';
import 'package:artisell/user/paint.dart';
import 'package:artisell/user/search.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import '../admin/adfashion.dart';
import '../admin/all.dart';
import '../admin/painting.dart';
import 'neww.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffd2cdbf),
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xff413821),
          actions: [
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'cart');
                    },
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    )))
          ],
          title: Center(
              child: Text(
            "Discover and collect",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ))),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(onTap:(){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>search()));
              } ,
                child: Container(
                  width: 350,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "search",
                      style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: CarouselSlider(
                items: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FurnitureContainer(
                          imageUrl: "lib/asset/img_3.png",
                          title1: "hand bags collections",
                          title2: "",
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FurnitureContainer(
                          imageUrl: "lib/asset/img_2.png",
                          title1: " home decor collections",
                          title2: "",
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FurnitureContainer(
                          imageUrl: "lib/asset/image.png",
                          title1: "hand bags collections",
                          title2: "",
                        ),
                      ],
                    ),
                  ),
                ],
                options: CarouselOptions(
                  height: 180,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(
                    microseconds: 2000,
                  ),
                  viewportFraction: 0.8,
                )),
          ),
          SizedBox(
            width: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("New Collections",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            ),
          ),
          Expanded(child: paint()),
        ],
      ),
      //
    );
  }
}
// Import this for the BackdropFilter class

class FurnitureContainer extends StatelessWidget {
  final String imageUrl;
  final String title1;
  final String title2;

  FurnitureContainer({
    required this.imageUrl,
    required this.title1,
    required this.title2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 315,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          // Image with Glass Mirror Effect
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
              child: Image.asset(
                imageUrl, // Assuming imageUrl points to the glass mirror image
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
