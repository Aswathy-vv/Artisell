

import 'package:artisell/admin/shome.dart';
import 'package:artisell/user/bottomnav.dart';
import 'package:artisell/user/signup.dart';
import 'package:artisell/user/home.dart';
import 'package:artisell/user/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatelessWidget {
  SignIn({super.key});

  TextEditingController password = TextEditingController();
  TextEditingController emailid = TextEditingController();


  Future<void> signin(BuildContext context) async {
    final Email = emailid.text.trim();
    final Password = password.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: Email, password: Password);

      if (Email == 'admin@gmail.com' && Password == 'admin123') {
        saveUserDetails('admin@gmail.com', isAdmin: true);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Shome()));
      } else {
        saveUserDetails(FirebaseAuth.instance.currentUser!.uid, isAdmin: false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => homepage(userid: FirebaseAuth.instance.currentUser!.uid)));
      }
    } on FirebaseAuthException catch (e) {
      print('Error during sign in: ${e.message}');
      print(e);
      final errorMessage = "Email and password do not match";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orangeAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        content: Text(errorMessage),
      ));
    }
  }

  void saveUserDetails(String userId, {required bool isAdmin}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userId);
    prefs.setBool('isAdmin', isAdmin);
  }

  void saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                  Colors.deepOrange,
                  Colors.orange,
                  Colors.orangeAccent,
                ])),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 80,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Get Started",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ]),
                  ),
                  Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)),
                          ),
                          child: SingleChildScrollView(physics: NeverScrollableScrollPhysics(),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Color.fromARGB(
                                                    225, 95, 27, 3),
                                                blurRadius: 20,
                                                offset: Offset(0, 10)),
                                          ],
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.white))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            TextField(
                                              controller: emailid,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintStyle:
                                                  TextStyle(color: Colors.grey),
                                                  hintText: "Enter the email"),
                                            ),
                                            TextField(
                                              controller: password, obscureText: true,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintStyle:
                                                  TextStyle(color: Colors.grey),
                                                  hintText: "Enter the password"),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            AlertDialog(
                                                title: Text("Password reset"),
                                                content: TextFormField(decoration: InputDecoration(hintText: "enter your email"),
                                                  controller: emailid,), actions: [
                                              TextButton(onPressed: () {},
                                                  child: TextButton(
                                                    onPressed: () {
                                                      resetpassword(context);Navigator.pop(context);
                                                    },
                                                    child: Text("ok"),))
                                            ]),
                                      );
                                    },
                                    child: Text(
                                      "Forgot password?",
                                      style: TextStyle(color: Colors.grey[800]),
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(150, 40),
                                        backgroundColor: Colors.orange),
                                    onPressed: () {
                                      signin(context);
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(color: Colors.white),
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "you have not a account?",
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SignUp()));
                                    },
                                    child: Text(
                                      "Signup",
                                      style: TextStyle(color: Colors.orange),
                                    ))
                              ],
                            ),
                          ))),
                ]),
          ),
        );
  }

  Future resetpassword(context) async {
    final email = emailid.text;
    if (email.contains('@')) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Color.fromARGB(255, 6, 157, 21),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        content: Text("Reset email has been send to $email"),
      ));
      Navigator.pushNamed(context, 'signin');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Color.fromARGB(255, 6, 157, 21),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        content: Text("error correct email"),
      ));
    }
  }
}
