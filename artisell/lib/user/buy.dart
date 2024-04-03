import 'package:artisell/user/succesfull.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class buy extends StatefulWidget {
  const buy({super.key});

  @override
  State<buy> createState() => _mycartState();
}
class _mycartState extends State<buy> {
  final CollectionReference Buy =
  FirebaseFirestore.instance.collection('buy');
  late List<DocumentSnapshot> buyitems = [];
int quantity=1;
  void delete(id) {
    Buy.doc(id).delete();
  }
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('details')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        // Handle the case when details are not found
        return {};
      }
    } catch (error) {
      print('Error fetching user details: $error');
      return {};
    }
  }
  final CollectionReference order =
  FirebaseFirestore.instance.collection('order');
  void placeOrder(String userId, String name, String itemname, String phone, List<DocumentSnapshot> items) async {
    try {
      // Retrieve current stock and update order details for each item in a transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Iterate through each item in the order
        for (var item in items) {
          String itemId = item.id;
          int quantity = item['quantity'];

          // Fetch current stock value
          DocumentSnapshot snapshot = await transaction.get(buy.doc(itemId));
          int currentStock = snapshot['stock'];

          // Ensure there's enough stock to fulfill the order
          if (currentStock < quantity) {
            throw 'Not enough stock available for ${item['productName']}!';
          }

          // Update stock for the specific item in 'buy' collection
          transaction.update(buy.doc(itemId), {'stock': currentStock - quantity});

          // Update order details in 'order' collection
          DocumentReference newOrderRef = order.doc();
          await newOrderRef.set({
            'userId': userId,
            'name': name,
            'itemname': itemname,
            'phone': phone,
            'total': calculateTotalWithDelivery(items),
            'items': items.map((item) {
              return {
                'productName': item['productName'],
                'image': item['image'],
                'price': item['price'],
                'quantity': item['quantity'],
                'stock':item['stock'],
              };
            }).toList(),
            'timestamp': FieldValue.serverTimestamp(),
          });
          String productName = snapshot['productName'];
          // Update stock in another collection
          await FirebaseFirestore.instance.collection('stock_updates').add({
            'itemId': itemId,
            'updatedStock': currentStock - quantity,
            'timestamp': FieldValue.serverTimestamp(),
            'productName': productName,
          });
        }
      });

      // Navigate to success screen if the order is successfully placed
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => success()),
      // );
    } catch (error) {
      print('Error placing order: $error');
      // Handle error here, e.g., show an error message to the user
    }
  }


  void updatestock(String id, int newstock) {
    buy.doc(id).update({'stock': newstock});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        height: 200,
        color: Color(0xffd2cdbf),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("price of  items"),
                  Text("₹${calculateTotal(buyitems)}"),
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
                  "₹${calculateTotalWithDelivery(buyitems)}",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(300, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Color(0xff6c1812),
                  ),
                  onPressed: buyitems.isNotEmpty
                      ?() async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => success()),
                    );
                    String userId =
                        FirebaseAuth.instance.currentUser!.email ?? '';

                    // Retrieve user details from 'details' collection
                    Map<String, dynamic> userDetails =
                    await getUserDetails(userId);

                    // Check if userDetails is not empty before proceeding
                    if (userDetails.isNotEmpty) {
                      // Extract details from userDetails
                      String name = userDetails['name'];
                      String location = userDetails['location'];
                      String phone = userDetails['phone'];
                      // Place order using retrieved details
                      placeOrder(userId, name, location, phone, buyitems);

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => success()),
                      // );
                    } else {
                      // Handle the case when user details are not found
                      print('User details not found');
                    }
                  }:null,
                  child: Text("confirm order", style: TextStyle(fontSize:25,color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xffd2cdbf),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('buy')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            QuerySnapshot admin = snapshot.data as QuerySnapshot;
            Future.microtask(() {
              setState(() {
                buyitems = snapshot.data.docs;
              });
            });
            return snapshot.data.docs.isEmpty
                ? Center(
              child: CircularProgressIndicator(backgroundColor: Colors.blueAccent,)
            )
                : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    final DocumentSnapshot admin = buyitems[index];
                    int quantity = admin['quantity'] ?? 0;
                    int stock = admin['stock'] ?? 0;
                    return Stack(
                      children: [
                        Container(
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
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Image(
                                    fit: BoxFit.fill,
                                    height: 50,
                                    width: 50,
                                    image: NetworkImage(buyitems[0]['image'] ??
                                        'https://example.com/default-image.jpg'),
                                    errorBuilder: (BuildContext context,
                                        Object error, StackTrace? stackTrace) {
                                      print('Error loading image: $error');
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      buyitems[0]['productName'],
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(height: 10,),
                                    Text(
                                      buyitems[0]['price'],
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: Color(0xffd2cdbf),
                                            borderRadius: BorderRadius.circular(
                                                50),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              updateQuantity(
                                                buyitems[0].id,
                                                buyitems[0]['quantity'] - 1,
                                              );
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
                                            color: Color(0xffd2cdbf),
                                            borderRadius: BorderRadius.circular(
                                                50),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              updateQuantity(
                                                buyitems[0].id,
                                                buyitems[0]['quantity'] + 1,
                                              );
                                            },
                                            icon: Icon(Icons.add),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
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
    );
  }
  final CollectionReference buy = FirebaseFirestore.instance.collection(
      "buy");

  void updateQuantity(String id, int newQuantity) {
    buy.doc(id).update({'quantity': newQuantity});
  }



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
}

