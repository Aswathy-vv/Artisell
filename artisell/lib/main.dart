

import 'package:artisell/admin/adminchat.dart';


import 'package:artisell/admin/shome.dart';
import 'package:artisell/admin/product.dart';
import 'package:artisell/user/bottomnav.dart';
import 'package:artisell/user/addresspage.dart';
import 'package:artisell/user/mycart.dart';
import 'package:artisell/user/ordersubmit.dart';
import 'package:artisell/user/detailspage.dart';
import 'package:artisell/user/signin.dart';
import 'package:artisell/user/succesfull.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'user/buynoworder.dart';
import 'user/addresspage2.dart';
import 'user/signup.dart';
import 'user/home.dart';
import 'user/wishlist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs=await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');


  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDOFe1EfkhHnNUGORjxFfGTkYeZBFEr2a4",
          appId:"1:154039801700:android:0a2542c8172e7151404c71",

          messagingSenderId: "154039801700",
          projectId: "artisell-ce1bd",
      storageBucket: "artisell-ce1bd.appspot.com",
      ));
  runApp(ProviderScope(child:MaterialApp(routes: {'show':(context)=>show(),
    'cart':(context)=>MyCart(),
    '/chat':(context)=>ChatScreenn(),
    'signin':(context)=>SignIn(),
    'detail':(context)=>Details(),
    'myproduct':(context)=>product(),
    'buynow':(context)=>buynow(),
    'success':(context)=>success(),
  },
    debugShowCheckedModeBanner: false,
    home: SplashScreen(userId: userId),)));
}


class SplashScreen extends StatelessWidget {
  final String? userId;

  SplashScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add a delay of 2 seconds before navigating to the home page
    Future.delayed(Duration(seconds: 2), () {
      if (userId != null && userId == 'admin@gmail.com') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Shome(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => userId != null ? homepage(userid: userId!) : SignIn(),
          ),
        );
      }
    });
    return Scaffold(backgroundColor:Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo image here
            Image.asset(
              "lib/asset/logo.jpg",
              width: 300, // Adjust the width as needed
              height: 300, // Adjust the height as needed
            ),
            Text("ARTISELL",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
