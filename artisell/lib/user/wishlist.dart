import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class wishlist extends StatefulWidget {
  wishlist({super.key});

  final CollectionReference wish =
      FirebaseFirestore.instance.collection('wish');

  @override
  State<wishlist> createState() => _wishlistState();
}

class _wishlistState extends State<wishlist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffd2cdbf),
        appBar: AppBar( automaticallyImplyLeading: false,
            backgroundColor: Color(0xff413821),
            title: Center(
              child: Text(
                "wishlist",
                style: TextStyle(color: Colors.white),
              ),
            )),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('wish')
              .where('userId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return snapshot.data.docs.isEmpty
                  ? Center(
                      child: Text(
                        'Your wishlist is empty. Add items to your wishlist.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        final DocumentSnapshot admin =
                            snapshot.data.docs[index];
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, 'show', arguments: {
                                "url": admin["image"],
                                "feature": admin["description"],
                                "name": admin["productName"],
                                "prices": admin["price"],
                              });
                            },
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Image(
                                            fit: BoxFit.fill,
                                            height: 70,
                                            width: 70,
                                            image: NetworkImage(admin['image'] ??
                                                'https://example.com/default-image.jpg'),
                                            errorBuilder: (BuildContext context,
                                                Object error,
                                                StackTrace? stackTrace) {
                                              print(
                                                  'Error loading image: $error');
                                              return const Icon(Icons.error);
                                            }),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        children: [
                                          Text(admin['productName'],
                                              style: TextStyle(
                                                fontSize: 20,
                                              )),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          // Text(admin['description']),
                                          Text(admin['price'],
                                              style: TextStyle(
                                                fontSize: 30,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 50,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: snapshot.data?.docs.length,
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
        ));
  }
}
