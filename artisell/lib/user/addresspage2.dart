
import 'package:artisell/user/bynowcart.dart';
import 'package:artisell/user/ordersubmit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'buynoworder.dart';
import 'mycart.dart';

class Details extends StatefulWidget {
  Details({Key? key}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final CollectionReference details =
  FirebaseFirestore.instance.collection("details");
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController itemname = TextEditingController();
  loc.Location locationService = loc.Location();

  bool detailsSubmitted = false;

  @override
  void initState() {
    super.initState();
    checkSubmissionStatus();
  }

  void addd(BuildContext context) async {
    final data = {
      'name': name.text,
      'phone': phone.text,
      'location': location.text,
      'itemname': itemname.text,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': FirebaseAuth.instance.currentUser!.email!
    };

    String userEmail = FirebaseAuth.instance.currentUser!.email!;
    await details.doc(userEmail).set(data);

    // Mark details as submitted
    await markDetailsAsSubmitted();

    navigateToNextPage(context);
  }


  Future<void> checkSubmissionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userEmail = FirebaseAuth.instance.currentUser!.email!;
    detailsSubmitted = prefs.getBool('$userEmail-detailsSubmitted') ?? false;
    if (detailsSubmitted) {
      // Navigate to the next page if details have been submitted
      navigateToNextPage(context);
    }
  }

  Future<void> markDetailsAsSubmitted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userEmail = FirebaseAuth.instance.currentUser!.email!;
    await prefs.setBool('$userEmail-detailsSubmitted', true);
  }

  void navigateToNextPage(BuildContext context) {
    // Replace current page with a new one
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Buynow()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  backgroundColor: Color(0xffd2cdbf),
    appBar: AppBar(automaticallyImplyLeading: false, leading: IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Icons.arrow_back,color: Colors.white,),
    ),backgroundColor: Color(0xff413821),title: Text("Address",style: TextStyle(color: Colors.white)),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: SafeArea(top: true,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: name,
                      enabled: !detailsSubmitted,
                      decoration: InputDecoration(
                        labelText: "Name",
                        hintText: "Enter a name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: phone,maxLength: 10, // Limit the character count to 10
                      keyboardType: TextInputType.phone, // Set the keyboard type to phone// Allow only digits
                      enabled: !detailsSubmitted,
                      decoration: InputDecoration(
                        labelText: "Phone",
                        hintText: "Enter a phone number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                TextFormField(
                  controller: location,maxLength: 6,keyboardType: TextInputType.phone,
                  enabled: !detailsSubmitted,
                  decoration: InputDecoration(
                    labelText: "pincode",
                    hintText: "Enter a pincode",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                    SizedBox(height: 30),
                       TextFormField(
                        controller: itemname,
                        enabled: !detailsSubmitted,
                        decoration: InputDecoration(
                          labelText: "address",
                          hintText: "Enter your address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    SizedBox(height: 30),
                    SingleChildScrollView(scrollDirection: Axis.vertical,
                      child: ElevatedButton(style: ElevatedButton.styleFrom( backgroundColor: Color(0xff6c1812),),
                        onPressed: detailsSubmitted ? null : () => addd(context),
                        // Disable the button if details are already submitted
                        child: Text("Submit",style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}