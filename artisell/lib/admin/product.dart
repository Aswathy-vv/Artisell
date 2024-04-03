import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class product extends StatefulWidget {
  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<product> {
  List<String> _collectionNames = ['neww', 'add', 'All', 'fashion'];
  List<String> _displayNames = ['New', 'painting', 'homedecor', 'Fashion']; // Display names for tabs
  List<String> _tabViewNames = ['New ', 'painting', 'homedecor', 'Fashion ']; // Names for TabBarViews

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _collectionNames.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('All Products'),
          bottom: TabBar(
            tabs: _displayNames.map((displayName) { // Using display names for tabs
              return Tab(
                text: displayName,
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: _collectionNames.map((collectionName) {
            int index = _collectionNames.indexOf(collectionName);
            return _ProductList(collectionName: collectionName, tabViewName: _tabViewNames[index]);
          }).toList(),
        ),
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final String collectionName;
  final String tabViewName;

  _ProductList({required this.collectionName, required this.tabViewName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Map<String, dynamic>> products = [];
          snapshot.data!.docs.forEach((doc) {
            if (doc.exists && doc.data() != null) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if (data.containsKey('itemname') && data.containsKey('price')) {
                products.add({
                  'id': doc.id,
                  'itemname': data['itemname'],
                  'feature': data['feature'],
                  'price': data['price'],
                  'image': data['image'],
                });
              } else {
                print('Document with unexpected structure: ${doc.id}');
              }
            }
          });

          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: products.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(product['image']), // Assuming 'image' is the URL of the product image
                ),
                title: Text(product['itemname']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: ${product['price']}'), // Assuming 'price' is the price of the product
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateProductScreen(
                              collectionName: collectionName,
                              productId: product['id'],
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Delete Product'),
                              content: Text('Are you sure you want to delete this product?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteProduct(product['id'], collectionName);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> _deleteProduct(String productId, String collectionName) async {
    await FirebaseFirestore.instance.collection(collectionName).doc(productId).delete();
  }
}

class UpdateProductScreen extends StatefulWidget {
  final String collectionName;
  final String productId;

  const UpdateProductScreen({Key? key, required this.collectionName, required this.productId}) : super(key: key);

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _stockController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection(
        widget.collectionName).doc(widget.productId).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      _itemNameController.text = data['itemname'] ?? '';
      _descriptionController.text = data['feature'] ?? '';

      _priceController.text = data['price']?.toString() ?? '';
      _imageController.text = data['image'] ?? '';
    }
  }

  Future<void> _updateProduct() async {
    String itemName = _itemNameController.text.trim();
    String description = _descriptionController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    String image = _imageController.text.trim();

    await FirebaseFirestore.instance.collection(widget.collectionName).doc(
        widget.productId).update({
      'itemname': itemName,
      'feature': description,
      'price': price,
      'image': image,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),

            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Price',
              ),
            ),
            TextField(
              controller: _imageController,
              decoration: InputDecoration(
                labelText: 'Image URL',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProduct,
              child: Text('Update Product'),
            ),
          ],
        ),

      ),
    );
  }

  @override

  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();

    super.dispose();
  }
}
