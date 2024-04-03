import 'package:artisell/user/bynowcart.dart';
import 'package:artisell/user/addresspage.dart';
import 'package:artisell/user/ordersubmit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'addresspage2.dart';

class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _mycartState();
}

class _mycartState extends State<MyCart> {
  final CollectionReference cart1 =
      FirebaseFirestore.instance.collection('cart1');
  late List<DocumentSnapshot> cartItems = [];

  // Future delete(id) async{
  //   await cart1.doc(id).delete();
  // }
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      final snapshot = await cart1
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();
      setState(() {
        cartItems = snapshot.docs;
      });
    } catch (error) {
      print('Error fetching cart items: $error');
    }
  }

  Future<void> delete(String id) async {
    try {
      await cart1.doc(id).delete();
      // After deleting, fetch the updated cart items
      fetchCartItems();
    } catch (error) {
      print('Error deleting item: $error');
    }
  }

  // int calculateTotalQuantity(List<DocumentSnapshot> items) {
  //   int totalQuantity = 0;
  //   for (var item in items) {
  //     int quantity = item['quantity'] ?? 0;
  //     totalQuantity += quantity;
  //   }
  //   return totalQuantity;
  // }
  double calculateTotalWithDelivery(List<DocumentSnapshot> items) {
    double total = calculateTotal(items);
    // Add delivery charge of $80
    total += 80;
    return total;
  }

  double calculateTotal(List<DocumentSnapshot> items) {
    double total = 0;
    for (var item in items) {
      final cleanedPrice = item['price'].replaceAll(RegExp(r'[^\d.]'), '');

      // Add this line for debugging
      print('Cleaned Price for item ${item['productName']}: $cleanedPrice');

      final quantity = item['quantity'] ?? 1;
      try {
        total += double.parse(cleanedPrice) * quantity;
      } catch (e) {
        print('Error parsing double for item ${item['productName']}: $e');
      }
    }
    return total;
  }

  void updateQuantity(String id, int newQuantity) {
    cart1.doc(id).update({'quantity': newQuantity});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffd2cdbf),
      appBar: AppBar(leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back,color: Colors.white,),
      ),
          backgroundColor: Color(0xff413821),
          title: Center(
              child: Text(
            "My Cart",
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ))),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cart1')
            .where('userId',
                isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
            Future.microtask(() {
              setState(() {
                cartItems = snapshot.data.docs;
              });
            });
            return cartItems.isEmpty
                ? Center(
                    child: Text(
                      'Your cart is empty. Add items to your cart.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        final DocumentSnapshot admin = cartItems[index];
                        int quantity = admin['quantity'] ?? 0;
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, 'show',
                                      arguments: {
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
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          width: 120,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Image(
                                              fit: BoxFit.fill,
                                              height: 50,
                                              width: 80,
                                              image: NetworkImage(admin[
                                                      'image'] ??
                                                  'https://example.com/default-image.jpg'),
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object error,
                                                      StackTrace? stackTrace) {
                                                print(
                                                    'Error loading image: $error');
                                                return const Icon(Icons.error);
                                              }),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(admin['productName'],
                                                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(admin['price'],
                                                  style: TextStyle(fontSize: 20)),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                          color:
                                                          Color(0xffd2cdbf),
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(50)),
                                                      child: IconButton(
                                                        onPressed: () {
                                                          updateQuantity(
                                                              admin.id,
                                                              admin['quantity'] -
                                                                  1);
                                                        },
                                                        icon: Icon(Icons.remove),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text('$quantity'),
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                          color:
                                                          Color(0xffd2cdbf),
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(50)),
                                                      child: IconButton(
                                                        onPressed: () {
                                                          updateQuantity(
                                                              admin.id,
                                                              admin['quantity'] +
                                                                  1);
                                                        },
                                                        icon: Icon(Icons.add),
                                                      ),
                                                    ),
                                                    // Text('$quantity'),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),

                                        IconButton(
                                            onPressed: () {
                                              delete(admin.id);
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      itemCount: cartItems.length,
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
      ),
      bottomNavigationBar: BottomAppBar(
        height: 200,
        color:Color(0xffd2cdbf),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("price"),
                    Text("₹${calculateTotal(cartItems)}"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("delivery charge"),
                    Text("₹80"),
                  ],
                ),
                ListTile(
                    title: Text("Total", style: TextStyle(fontSize: 20)),
                    trailing: Text(
                      "₹${calculateTotalWithDelivery(cartItems)}",
                      style: TextStyle(fontSize: 20),
                    )),
                Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(300, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: Color(0xff6c1812),
                        ),
                        onPressed: cartItems.isNotEmpty
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Details()),
                          );
                        }
                            :null,
                        child: Text(
                          "placeorder",
                          style: TextStyle(color: Colors.white, fontWeight:FontWeight.normal,fontSize: 25),
                        )))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
