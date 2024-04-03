import 'package:artisell/user/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class success extends StatefulWidget {
  const success({super.key});

  @override
  State<success> createState() => _successState();
}

class _successState extends State<success> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Lottie.asset("lib/asset/anima.json", height: 300),
          ),
          Text(
            "Order successfull",
            style: TextStyle(fontSize: 30, color: Colors.black),
          ),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => homepage(userid: 'user')));
              },
              child: Text("return Home"))
        ],
      )),
    );
  }
}
