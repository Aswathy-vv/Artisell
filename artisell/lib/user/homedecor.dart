import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Content for each tab goes here
class homedecor extends StatefulWidget {
  homedecor({Key? key}) : super(key: key);

  @override
  State<homedecor> createState() => _homedecorState();
}

class _homedecorState extends State<homedecor> {
  final CollectionReference all = FirebaseFirestore.instance.collection("All");

  final CollectionReference cart1 = FirebaseFirestore.instance.collection("cart1");

  bool isAddingToCart = false;


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
                        color:Color(0xffd2cdbf),
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
                          Container(
                            child: Text(
                              admin['itemname'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
        stream: all.orderBy('image', descending: true).snapshots(),
      ),
    );
  }
}
