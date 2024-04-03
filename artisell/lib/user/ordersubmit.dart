import 'package:artisell/user/bynowcart.dart';
import 'package:artisell/user/succesfull.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'addresspage2.dart';

class Buynow extends StatefulWidget {
   Buynow({super.key});

  @override
  State<Buynow> createState() => _buynowState();
}
class _buynowState extends State<Buynow> {


  final CollectionReference details =
  FirebaseFirestore.instance.collection("details");
  final CollectionReference cart1 =
  FirebaseFirestore.instance.collection("cart1");
  late List<DocumentSnapshot> cartItems = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController itemnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back,color: Colors.white,),
      ),
          backgroundColor: Color(0xff413821),
          title: Center(
            child: Text(
              "order summery",
              style: TextStyle(color: Colors.white),
            ),
          )),
      backgroundColor: Color(0xffd2cdbf),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('details')
            .where('userId',
                isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            QueryDocumentSnapshot admin = snapshot.data!.docs[0];
            nameController.text = admin['name'];
            phoneController.text = admin['phone'];
            locationController.text = admin['location'];
            itemnameController.text = admin['itemname'];
            String name = admin['name'];
            String phone = admin['phone'];
            String location = admin['location'];
            String itemname = admin['itemname'];
            return snapshot.data!.docs.isEmpty
                ? Center(
              child: Text(
                'Your cart is empty. Add items to your cart.',
                style: TextStyle(fontSize: 16),
              ),
            ) :Column(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Deliver to",
                            style: TextStyle(color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 20,),
                        name.isNotEmpty ? Align(alignment:Alignment.centerLeft,child: Text(name,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)) : Text(
                            "Name is empty"),
                        phone.isNotEmpty ? Align(alignment:Alignment.centerLeft,child: Text(phone,style: TextStyle(fontSize: 15),)) : Text(
                            "Phone is empty"),
                        itemname.isNotEmpty ? Align(alignment:Alignment.center,child: Text(itemname,style: TextStyle(fontSize: 15),)) : Text(
                            "pincode is empty"),
                        location.isNotEmpty ? Align(alignment:Alignment.centerLeft,child: Container(height:100,width:200,child: Text(location,style: TextStyle(fontSize: 15),))) : Text(
                            "address is empty"),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                 SizedBox(width: 50,),
                  SingleChildScrollView(scrollDirection:Axis.horizontal ,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .green[900]),
                        onPressed: () {_showUpdateForm(context);
                        },
                        child: Text("Edit",
                          style: TextStyle(color: Colors.white),)),
                  )
                ],
              ),
            ),
            Expanded(child: buynowcart(),
            )
          ]);
        }
        else if (snapshot.hasError) {
          return Container(child: Text(snapshot.error.toString()),);
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return Container();
        }
      },
      ),
    );
  }
  void _showUpdateForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Details"),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                  ),
                  TextFormField(
                    controller: phoneController,maxLength: 10, // Limit the character count to 10
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: "Phone"),
                  ),
                  TextFormField(
                    controller: locationController,maxLength: 6, // Limit the character count to 10
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: "pincode"),
                  ),
                  TextFormField(
                    controller: itemnameController,
                    decoration: InputDecoration(labelText: "Address"),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _updateDetails(context);
                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }


  // Function to update details
  void _updateDetails(BuildContext context) async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser!.email!;

      // Update the existing details
      await details.doc(userEmail).update({
        'name': nameController.text,
        'phone': phoneController.text,
        'pincode': locationController.text,
        'itemname': itemnameController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show a dialog to inform the user that the details have been updated
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Details Updated'),
            content: Text('Details updated successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error updating details: $e');
    }
  }
}




