import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'addresspage.dart';

class show extends StatefulWidget {
  show({Key? key}) : super(key: key);

  @override
  State<show> createState() => _showState();
}

class _showState extends State<show> {
  final CollectionReference fashion =
  FirebaseFirestore.instance.collection("fashion");
  final CollectionReference all = FirebaseFirestore.instance.collection("All");
  final CollectionReference neww = FirebaseFirestore.instance.collection("neww");
  final CollectionReference add = FirebaseFirestore.instance.collection("add");
  final CollectionReference wish = FirebaseFirestore.instance.collection("wish");
  final CollectionReference cart1 = FirebaseFirestore.instance.collection("cart1");
  final CollectionReference Buy = FirebaseFirestore.instance.collection("buy");
  Future<int?> getQuantityFromStockUpdates(String productName) async {
    try {
      // Query the stock_updates collection for the corresponding product
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('stock_updates')
          .where('productName', isEqualTo: productName)
          .get();

      // If there is at least one document matching the query
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document and return its updatedStock field
        return querySnapshot.docs.first['updatedStock'];
      } else {
        // If no document is found, return null
        return null;
      }
    } catch (e) {
      print("Error retrieving quantity from stock_updates collection: $e");
      return null;
    }
  }
  Future<void> buy(
      String productName, String description, String price, String image,) async {
    try {
      String? userEmail = FirebaseAuth.instance.currentUser!.email;
      CollectionReference buyCollection =
      FirebaseFirestore.instance.collection('buy');

      QuerySnapshot querySnapshot = await buyCollection
          .where('userId', isEqualTo: userEmail)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      // Get the quantity from the stock_updates collection
      int? quantity = await getQuantityFromStockUpdates(productName);
      if (quantity == null) {
        // If quantity is null, handle the case accordingly (e.g., set a default value)
        quantity = 20;
      }

      await buyCollection.add({
        'productName': productName,
        'price': price,
        'image': image,
        'quantity': 1,
        'stock': quantity,
        'userId': userEmail,
      });
    } catch (e) {
      print("Error: $e");
    }
  }
  bool isaddcart = false;
  Future<void> addToCart(
      String productName,
      String description,
      String price,
      String image,
      ) async {
    try {
      String? userEmail = FirebaseAuth.instance.currentUser?.email!;

      QuerySnapshot querySnapshot = await cart1
          .where('userId', isEqualTo: userEmail)
          .where('productName', isEqualTo: productName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Item already exists in cart, navigate to cart page
        Navigator.pushNamed(context, 'cart');
        return;
      }
      int? quantity = await getQuantityFromStockUpdates(productName);
      if (quantity == null) {
        // If quantity is null, handle the case accordingly (e.g., set a default value)
        quantity = 20;
      }

      // Item not in cart, add it
      await cart1.add({
        'quantity': 1,
        'productName': productName,
        'description': description,
        'price': price,
        'image': image,
        'stock':quantity,
        'userId': userEmail,
      });

      // Show snackbar for successful addition
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Color.fromARGB(255, 6, 157, 21),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        content: Text("Item added to cart"),
      ));

      // Update the isaddcart state to true
      setState(() {
        isaddcart = true;
      });

    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> removeFromCart(String productName) async {
    try {
      String? userEmail = FirebaseAuth.instance.currentUser?.email!;
      QuerySnapshot querySnapshot = await cart1
          .where('userId', isEqualTo: userEmail)
          .where('productName', isEqualTo: productName)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await cart1.doc(doc.id).delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        content: Text("Item removed from cart"),
      ));
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<bool> addOrRemoveFromWishlist(
      String productName, String description, String price, String image) async {
    try {
      QuerySnapshot querySnapshot = await wish
          .where('productName', isEqualTo: productName)
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();

      bool isProductInWishlist = querySnapshot.docs.isNotEmpty;
      if (isProductInWishlist) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          content: Text("Item removed from wishlist "),
        ));
        return false;
      } else {
        await wish.add({
          'productName': productName,
          'description': description,
          'price': price,
          'image': image,
          'userId': FirebaseAuth.instance.currentUser!.email,
        });ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          content: Text("Item added to wishlist"),
        ));
        return true;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }



  @override
  late SharedPreferences prefs;
  bool isliked = false;
  User? user;
  String? name;
  String? prices;
  String? feature;
  String? url;

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;
    initializeSharedPreferences().then((_) {
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      name = args?["name"];
      loadLikedState();
      loadcartState();
    });
  }

  Future<void> initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    print("SharedPreferences initialized");
  }

  String getcartKey(String itemName) {
    return '${user?.email}_cartState_$itemName';
  }

  Future<void> savecartState(bool isaddcart) async {
    await prefs.setBool(getcartKey(name!), isaddcart);
    print("Saved Cart State: $isaddcart");
  }

  Future<void> loadcartState() async {
    if (prefs != null && name != null) {
      setState(() {
        isaddcart = prefs.getBool(getcartKey(name!)) ?? false;
        print("Loaded Cart State: $isaddcart");
      });
    }
  }

  String getLikeKey(String itemName) {
    return '${user?.email}_likedState_$itemName';
  }

  Future<void> loadLikedState() async {
    if (prefs != null && name != null) {
      setState(() {
        isliked = prefs.getBool(getLikeKey(name!)) ?? false;
        print("Loaded Liked State: $isliked");
      });
    }
  }

  Future<void> saveLikedState(bool isLiked) async {
    await prefs.setBool(getLikeKey(name!), isLiked);
    print("Saved Liked State: $isLiked");
  }

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        body: Center(
          child: Text("Invalid data or missing arguments"),
        ),
      );
    }

    final url = args?["url"];
    final name = args?["name"];
    final feature = args?["feature"];
    final prices = args?["prices"];

    return Scaffold(bottomNavigationBar: BottomAppBar(
      height: 100,
      color: Color(0xffd2cdbf),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    // If item is not in the cart, add it
                    addToCart(name, feature, prices, url);
                  });
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(350, 80), backgroundColor: Color(0xff6c1812),
                ),
                child: Text(
                  isaddcart ? "Add  Cart" : "Add Cart",
                  style: TextStyle(fontSize: 23, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Detailsb()));
                  buy(name, feature, prices, url);
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(140, 70), backgroundColor: Color(0xff413821),
                ),
                child: Text(
                  "Buy now",
                  style: TextStyle(fontSize: 23, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
      body: Column(
        children: [
          Expanded(
            child: Container( child:   Align(
      alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context); // Navigate back when the button is pressed
            },
            icon: Icon(Icons.arrow_back), // Back button icon
            color: Colors.black,iconSize: 30, // Customize the color of the icon
          ),
        ),
      ),

              width: double.infinity,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.green[200],
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(name,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Align(alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          prices,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      height: 290,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          feature,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            shape: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50)),
            onPressed: () async {
              isliked = !isliked;
              bool itemAdded =
              await addOrRemoveFromWishlist(name!, feature!, prices!, url!);
              setState(() {
                isliked = itemAdded;
                saveLikedState(isliked);
              });
            },
            child: Icon(
              isliked ? Icons.favorite : Icons.favorite_border,
              color: isliked ? Colors.red : null,
              size: 30,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}

