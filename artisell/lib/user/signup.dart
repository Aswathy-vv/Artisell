import 'package:artisell/user/home.dart';
import 'package:artisell/user/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});

  final TextEditingController password = TextEditingController();
 final  TextEditingController email = TextEditingController();
final  TextEditingController conpass = TextEditingController();
  final CollectionReference users =
  FirebaseFirestore.instance.collection("users");

  Future<void> signup(BuildContext context) async {
    final Password = password.text;
    final CPassword = conpass.text;

    if (Password == CPassword) {
      try {
        // Create user using Firebase Auth
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );

        // Add user data to Firestore if the user doesn't already exist
        addd();

        // Navigate to sign-in page after successful sign-up
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          content: Text("Account Successfully created"),
        ));
      } on FirebaseAuthException catch (e) {
        // Handle FirebaseAuthException errors
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          content: Text("Try again"),
        ));
      }
    } else {
      // Show password mismatch error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        content: Text("Password does not match"),
      ));
    }
  }

  void addd() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final data = {
        'email': email.text,
        'uid': currentUser.uid,
      };

      // Get a reference to the Firestore collection
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      // Check if the email already exists in the collection
      usersCollection.where('email', isEqualTo: data['email']).get().then((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          // Add the data to the collection if the email doesn't already exist
          usersCollection.add(data).then((_) {
            print("Data added successfully");
          }).catchError((error) {
            print("Failed to add data: $error");
          });
        } else {
          print("Email already exists in the collection");
        }
      }).catchError((error) {
        print("Error checking email existence: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget text(String? hintText, TextEditingController? controller,) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(controller: controller,obscureText: hintText!.toLowerCase().contains("password"),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
              hintText: hintText),
        ),
      );
    }

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
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Text(
                    "Create account",
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
                    child: SingleChildScrollView(physics:NeverScrollableScrollPhysics() ,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color.fromARGB(225, 95, 27, 3),
                                          blurRadius: 20,
                                          offset: Offset(0, 10)),
                                    ],
                                    border: Border(
                                        bottom: BorderSide(color: Colors.white))),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      text("enter  a email",email),
                                      text("enter a password",password),
                                      text("enter a confirm password",conpass),
                                    ],
                                  ),
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(150, 40),
                                  backgroundColor: Colors.orange),
                              onPressed: () {
                                signup(context);
                              },
                              child: Text(
                                "Signup",
                                style: TextStyle(color: Colors.white),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'signin');
                              },
                              child: Text(
                                "login",
                                style: TextStyle(color: Colors.orange),
                              ))
                        ],
                      ),
                    ))),
          ]),
    ));
  }
}
