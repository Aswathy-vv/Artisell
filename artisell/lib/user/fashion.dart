import 'dart:async';
import 'package:artisell/user/detailspage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:staggered_grid_view_flutter/rendering/sliver_staggered_grid.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class fashionn extends StatelessWidget {
  fashionn({Key? key}) : super(key: key);

  final CollectionReference fashion = FirebaseFirestore.instance.collection("fashion");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffd2cdbf),
      body: StreamBuilder(
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.52,
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final DocumentSnapshot admin = snapshot.data.docs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'show', arguments: {
                        "url": admin["image"],
                        "feature": admin["feature"],
                        "name": admin["itemname"],
                        "prices": admin["price"],
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xffd2cdbf),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 200, // Set a fixed height for the image
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(admin['image']),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            admin['itemname'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                admin['price'],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xffc0583a),
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Container(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            return Container();
          }
        },
        stream: fashion.orderBy('image', descending: true).snapshots(),
      ),
    );
  }
}

class New extends StatelessWidget {
  New({Key? key}) : super(key: key);

  final CollectionReference neww =
      FirebaseFirestore.instance.collection("neww");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffd9d3cb),
      body: StreamBuilder(
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: StaggeredGridView.builder(
                itemCount: snapshot.data?.docs.length,
                gridDelegate:
                    SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  staggeredTileBuilder: (int index) =>
                      StaggeredTile.count(1, index.isEven ? 1.6 : 1.6),
                ),
                itemBuilder: (BuildContext context, int index) {
                  final DocumentSnapshot admin = snapshot.data.docs[index];
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'show', arguments: {
                          "url": admin["image"],
                          "feature": admin["feature"],
                          "name": admin["itemname"],
                          "prices": admin["price"],
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xffd2cdbf),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                        admin['image'],
                                      )),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // Adjust the spacing as needed
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Text(
                                      admin['itemname'],
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          admin['price'],
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.orange[900]),
                                        ),


                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Container(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            return Container();
          }
        },
        stream: neww.orderBy('image', descending: true).snapshots(),
      ),
    );
  }
}
