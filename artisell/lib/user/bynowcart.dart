import 'package:artisell/user/succesfull.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class buynowcart extends StatefulWidget {
  const buynowcart({super.key});
  @override
  State<buynowcart> createState() => _mycartState();
}

class _mycartState extends State<buynowcart> {
  final CollectionReference cart1 =
      FirebaseFirestore.instance.collection('cart1');
  final CollectionReference details =
      FirebaseFirestore.instance.collection('details');
  late List<DocumentSnapshot> cartItems = [];
  final CollectionReference order =
      FirebaseFirestore.instance.collection('order');
  final CollectionReference stockUpdates =
  FirebaseFirestore.instance.collection('stock_updates');
  final CollectionReference search =
  FirebaseFirestore.instance.collection('search');

 int quantity=1;

  void delete(id) {
    cart1.doc(id).delete();
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
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> updateStockInCollection(String productName, int newStock) async {
    try {
      // Query 'stock_collections' to find documents where productName matches
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('stock_collections')
          .where('productName', isEqualTo: productName)
          .get();

      // Iterate over the matching documents
      querySnapshot.docs.forEach((doc) async {
        // Update the stock in each matching document
        await doc.reference.update({
          'stock': newStock,
        });
      });
    } catch (error) {
      print('Error updating stock collection: $error');
    }
  }

  void placeOrder(String userId, String name, String itemname, String phone, List<DocumentSnapshot> cartItems) async {
    try {
      // Start a Firestore transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Initialize list to store ordered items
        List<Map<String, dynamic>> orderedItems = [];

        // Fetch all cart items asynchronously
        List<DocumentSnapshot> fetchedCartItems = await Future.wait(cartItems.map((cartItem) async {
          String itemId = cartItem.id;
          int quantity = cartItem['quantity'];

          // Fetch current stock value from 'cart1' collection
          DocumentSnapshot cartItemSnapshot = await transaction.get(cart1.doc(itemId));
          int currentStock = cartItemSnapshot['stock'];

          // Ensure there's enough stock to fulfill the order
          if (currentStock < quantity) {
            throw 'Not enough stock available for ${cartItemSnapshot['productName']}!';
          }
          // Update stock for the specific item in 'cart1' collection
          transaction.update(cart1.doc(itemId), {'stock': currentStock - quantity});
          // Construct item details for the order and add to orderedItems list
          orderedItems.add({
            'productName': cartItemSnapshot['productName'],
            'image': cartItemSnapshot['image'],
            'price': cartItemSnapshot['price'],
            'quantity': quantity,
            'stock': currentStock - quantity, // Update stock in the ordered items
          });
          // Update stock in 'stock_collections' collection based on product name
          await updateStockInCollection(cartItemSnapshot['productName'], currentStock - quantity);

          // Update stock in another collection (optional)
          await FirebaseFirestore.instance.collection('stock_updates').add({
            'itemId': itemId,
            'updatedStock': currentStock - quantity,
            'timestamp': FieldValue.serverTimestamp(),
            'productName': cartItemSnapshot['productName'],
          });

          return cartItemSnapshot;
        }));

        // Update order details in 'order' collection after all items are processed
        DocumentReference newOrderRef = order.doc();
        await newOrderRef.set({
          'userId': userId,
          'name': name,
          'itemname': itemname,
          'phone': phone,
          'total': calculateTotalWithDelivery(cartItems),
          'items': orderedItems,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      // Navigate to success screen if the order is successfully placed

    } catch (error) {
      print('Error placing order: $error');
      // Handle error here, e.g., show an error message to the user
    }
  }


  Future<void> updateSearchCollection(
      String productName, int quantity) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('search')
          .where('productName', isEqualTo: productName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot productDoc = querySnapshot.docs.first;
        int currentStock = productDoc['stock'];

        // Update the stock value
        await _firestore.collection('search').doc(productDoc.id).update({
          'stock': currentStock - quantity,
        });
      }
    } catch (e) {
      print('Error updating search collection: $e');
    }
  }
  void updatestock(String id, int newstock) {
    cart1.doc(id).update({'stock': newstock});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        height: 200,
        color: Color(0xffd2cdbf),
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("price of items)"),
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
                title: Text("Total",style: TextStyle(fontSize: 20)),
                trailing: Text(
                  "₹${calculateTotalWithDelivery(cartItems)}",
                  style: TextStyle(fontSize: 20),
                )),
            Center(
                child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(300, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Color(0xff6c1812),
                  ),
              onPressed: () async {
                String userId = FirebaseAuth.instance.currentUser!.email ?? '';

                // Retrieve user details from 'details' collection
                Map<String, dynamic> userDetails = await getUserDetails(userId);

                // Check if userDetails is not empty before proceeding
                if (userDetails.isNotEmpty) {
                  // Extract details from userDetails
                  String name = userDetails['name'];
                  String location = userDetails['location'];
                  // String location = userDetails['itemname'];
                  String phone = userDetails['phone'];

                  // Place order using retrieved details
              placeOrder(userId, name, location, phone, cartItems);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => success()),
                  );

                } else {
                  // Handle the case when user details are not found
                  print('User details not found');
                }
              },
              child: Text("Confirm order",style: TextStyle(fontSize: 20,color: Colors.white),),
            ))
          ]),
        ),
      ),
      backgroundColor: Color(0xffd2cdbf),
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
            return Padding(
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
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Image(
                                        fit: BoxFit.fill,
                                        height: 80,
                                        width: 100,
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
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [

                                      // IconButton(
                                      //     onPressed: () {
                                      //       delete(admin.id);
                                      //     },
                                      //     icon: Icon(
                                      //       Icons.delete,
                                      //       color: Colors.red,
                                      //     )),

                                    ],
                                  )
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
    );
  }
  void updateQuantity(String id, int newQuantity) {
    cart1.doc(id).update({'quantity': newQuantity});
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
      final quantity = item['quantity'] ?? 1; // Default to 1 if quantity is not present
      total += double.parse(cleanedPrice) * quantity;
    }
    return total;
  }
}
