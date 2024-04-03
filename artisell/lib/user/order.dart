import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Myorder extends StatelessWidget {
  final CollectionReference order =
      FirebaseFirestore.instance.collection('order');

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor:  Color(0xffd2cdbf),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: Colors.white,),
          ),
          backgroundColor: Color(0xff413821),
          title: Text(
            'My orders',
            style: TextStyle(color: Color(0xffffffff)),
          ),
        ),
        body: StreamBuilder(
          stream: order
              .where('userId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return Center(child: CircularProgressIndicator());
              // }
              //
              // if (snapshot.hasError) {
              //   return Center(child: Text('Error: ${snapshot.error}'));
              // }
              //
              // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              //   return Center(child: Text('No orders available.'));
              // }

              return snapshot.data!.docs.isEmpty
                  ? Center(
                      child: Text(
                        'no order available',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = snapshot.data!.docs[index];
                        Map<String, dynamic> orderData =
                            document.data() as Map<String, dynamic>;
                        DateTime timestamp =
                            (orderData['timestamp'] as Timestamp).toDate();

                        return Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${_formatDate(timestamp)}'),
                              Text(
                                  'Total: ₹${orderData['total']}'),
                              Column(
                                children: (orderData['items'] as List<dynamic>)
                                    .map<Widget>((item) {
                                  return SingleChildScrollView(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xff736c5a).withOpacity(0.5),
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
                                              SizedBox(height: 10),

                                              SizedBox(height: 10),
                                            ],
                                          ),
                                          SizedBox(
                                              width: 10), // Adjust the spacing
                                          Image.network(
                                            '${item['image']}',
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
            }
            ;
            return Container();
          },
        ));
  }


  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }
}
