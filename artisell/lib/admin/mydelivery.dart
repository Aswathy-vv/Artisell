import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Order extends StatelessWidget {
  final CollectionReference order =
  FirebaseFirestore.instance.collection('order');
  final CollectionReference firstCollection = FirebaseFirestore.instance.collection('neww');
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.grey,
      appBar: AppBar(backgroundColor: Color(0xff2596be),
        title: Text('Order List',),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: order.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No orders available.');
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> orderData =
              document.data() as Map<String, dynamic>;
              DateTime timestamp =
              (orderData['timestamp'] as Timestamp).toDate();
              _decrementStockAndUpdateFirstCollection(orderData['items']);


              return Container(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('email: ${orderData['userId']}'),
                    SizedBox(height: 8.0),
                    Text('Name: ${orderData['name']}'),
                    Text('Location: ${orderData['location']}'),
                    Text('Phone: ${orderData['phone']}'),
                    Text('Total: ${orderData['total']}'),
                    SizedBox(height: 8.0),
                    Text('Items:'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${_formatDate(timestamp)}'),

                    Column(
                      children: (orderData['items'] as List<dynamic>)
                          .map<Widget>((item) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Product: ${item['productName']}'),
                                  Text('Price: ${item['price']}'),
                                  Text('quantity: ${item['quantity']}'),
                                  Text('stock: ${item['stock']}'),
                                  SizedBox(height: 10),
                                  Text(
                                      'Total: ₹${orderData['total']}'),
                                  SizedBox(height: 10),
                                ],
                              ),
                              SizedBox(
                                  width: 10), // Adjust the spacing
                              Image.network(
                                '${item['image']}',
                                height: 90,
                                width: 90,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
            ]  ));
            },
          );
        },
      ),
    );
  }
  Future<void> _decrementStockAndUpdateFirstCollection(List<dynamic> items) async {
    try {
      // Iterate through ordered items
      for (var item in items) {
        // Assuming 'productId' is the unique identifier for each product in the first collection
        String productId = item['productId'];

        // Fetch current stock quantity of the product
        DocumentSnapshot productDoc = await firstCollection.doc(productId).get();

        if (productDoc.exists) {
          int currentStock = productDoc['stock'] ?? 0;
          int quantityOrdered = item['quantity'];
          int updatedStock = currentStock - quantityOrdered;

          // Update the stock quantity in the first collection
          await firstCollection.doc(productId).update({'stock': updatedStock});
        }
      }
    } catch (error) {
      print('Error decrementing stock and updating first collection: $error');
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }
}
