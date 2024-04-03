import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Fashion extends StatefulWidget {
  Fashion({Key? key}) : super(key: key);

  @override
  _FashionState createState() => _FashionState();
}

class _FashionState extends State<Fashion> {
  final CollectionReference search =
  FirebaseFirestore.instance.collection("search");
  final CollectionReference All =
  FirebaseFirestore.instance.collection("All");

  XFile? _image;

  Future<XFile?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      print("Error picking image: $e");
    }
    return pickedFile;
  }

  Future<String> _uploadImage(XFile file) async {
    final storage = FirebaseStorage.instance;
    final ref =
    storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = ref.putFile(File(file.path));
    await uploadTask.whenComplete(() => null);

    final imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController about = TextEditingController();
  TextEditingController stock = TextEditingController();

  void addd(String imageUrl) {
    final data = {
      'image': imageUrl,
      'itemname': name.text,
      'feature': about.text,
      'price': price.text,
      'stock':stock.text,
    };
    All.add(data);
  }
  void searchs(String imageUrl) {
    final data = {
      'image': imageUrl,
      'itemname': name.text,
      'feature': about.text,
      'price': price.text,
    };
    search.add(data);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 90,
                  child: ClipOval(
                    child: Container(
                      width: 260,
                      height: 190,
                      child: _image == null
                          ? Center(child: Text('No image selected.'))
                          : Image.file(File(_image!.path)),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: () async {
                      XFile? pickedImage = await pickImage();
                      if (pickedImage != null) {
                        String imageUrl = await _uploadImage(pickedImage);
                        print("uploaded : ::::: $imageUrl");
                        setState(() {
                          _image = pickedImage;
                        });
                      }
                    },
                    icon: Icon(Icons.add_a_photo),
                  ),
                ),
              ],
            ),
          
            SizedBox(height: 20),
            TextFormField(
              controller: name,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: "itemname",
                hintText: "enter a name",
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: about,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: "about",
                hintText: "enter features",
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: price,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: "price",
                hintText: "enter a price",
              ),
            ),
            SizedBox(height: 20),
          
            ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor: Color(0xff063970),),
              onPressed: () {
                if (_image != null) {
                  _uploadImage(_image!).then((imageUrl) {
                    addd(imageUrl);
                    searchs(imageUrl);
resetState();                  });
                } else {
                  // Handle the case where no image is selected
                  print("Please select an image");
                }
              },
              child: Text("submit",style: TextStyle(color: Colors.white),),
            ),
          ]),
        ),
      ),
    );
  }void resetState() {
    setState(() {
      _image = null;
      name.clear();
      about.clear();
      price.clear();
      stock.clear();
    });
  }
}