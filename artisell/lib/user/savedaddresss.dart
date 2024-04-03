import 'package:artisell/user/bynowcart.dart';
import 'package:artisell/user/succesfull.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'addresspage2.dart';

class savedAddress extends StatefulWidget {
  savedAddress({super.key});

  @override
  State<savedAddress> createState() => _buynowState();
}

class _buynowState extends State<savedAddress> {
  final CollectionReference details =
      FirebaseFirestore.instance.collection("details");
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController itemnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: Color(0xffd2cdbf),
      appBar: AppBar(leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back,color: Colors.white,),
      ),
          backgroundColor: Color(0xff413821),
          title: Center(
            child: Text(
              "saved address",
              style: TextStyle(color: Colors.white),
            ),
          )),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('details')
            .where('userId',
                isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) { if (snapshot.data.docs.isEmpty) {
            return Center(
              child: Text(
                'Your saved address is empty. ',
                style: TextStyle(fontSize: 16),
              ),
            );
          }


            QueryDocumentSnapshot admin = snapshot.data!.docs[0];
            nameController.text = admin['name'];
            phoneController.text = admin['phone'];
            locationController.text = admin['location'];
            itemnameController.text = admin['itemname'];
            String name = admin['name'];
            String phone = admin['phone'];
            String location = admin['location'];
            String itemname = admin['itemname'];


            return snapshot.data.docs.isEmpty
                ? Center(
              child: Text(
                'Your cart is empty. Add items to your cart.',
                style: TextStyle(fontSize: 16),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: Container(child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(name),
                      ),
                        width: 500,height: 60,
                        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12,offset: Offset(0.0,1.0))],
                            borderRadius: BorderRadius.circular(20),
                            color:  Color(0xffd2cdbf),),
                      ),
                    ),
                    ListTile(
                      title: Container(child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(phone),
                      ),
                        width: 500,height: 60,
                        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12,offset: Offset(0.0,1.0))],
                            borderRadius: BorderRadius.circular(20),
                            color:Color(0xffd2cdbf),),
                      ),
                    ),
                    ListTile(
                      title: Container(child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(location),
                      ),
                        width: 500,height: 60,
                        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12,offset: Offset(0.0,1.0))],
                            borderRadius: BorderRadius.circular(20),
                            color:Color(0xffd2cdbf), ),
                      ),
                    ),
                    ListTile(
                      title: Container(child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(itemname),
                      ),
                        width: 500,height: 90,
                        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12,offset: Offset(0.0,1.0))],
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xffd2cdbf),),
                      ),
                    ),SizedBox(height: 30,),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(fixedSize: Size(100, 50),
                            backgroundColor: Colors.green[900],),
                        onPressed: () {
                          _showUpdateForm(context);
                        },
                        child: Text(
                          "Edit",
                          style: TextStyle(color: Colors.white,fontSize: 20),
                        ))
                  ],
                ),
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
                    decoration: InputDecoration(fillColor:Colors.grey,labelText: "Name"),
                  ),
                  TextFormField(
                    controller: phoneController,maxLength: 10, // Limit the character count to 10
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: "Phone",fillColor:Colors.grey,),
                  ),
                  TextFormField(
                    controller: locationController, keyboardType: TextInputType.phone,maxLength: 6,
                    decoration: InputDecoration(labelText: "pincode",fillColor:Colors.grey,),
                  ),
                  TextFormField(
                    controller: itemnameController,
                    decoration: InputDecoration(labelText: "Address",fillColor:Colors.grey,),
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
        'location': locationController.text,
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
