import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockUpdatesPage extends StatefulWidget {
  @override
  _StockUpdatesPageState createState() => _StockUpdatesPageState();
}

class _StockUpdatesPageState extends State<StockUpdatesPage> {
  late Stream<List<DocumentSnapshot>> stockUpdatesStream;
  TextEditingController _newStockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the stream to get stock updates
    stockUpdatesStream = getStockUpdates();
  }
  Stream<List<DocumentSnapshot>> getStockUpdates() {
    return FirebaseFirestore.instance
        .collection('stock_updates')
        .orderBy('timestamp', descending: true) // Sort by timestamp to get the latest updates first
        .snapshots()
        .map((querySnapshot) {
      // Group by product name and get the latest update for each product
      Map<String, DocumentSnapshot> latestUpdates = {};
      querySnapshot.docs.forEach((doc) {
        String productName = doc['productName'];
        if (!latestUpdates.containsKey(productName)) {
          latestUpdates[productName] = doc;
        }
      });
      return latestUpdates.values.toList();
    });
  }

  Future<void> _updateStock(String productId, int newStock) async {
    // Update the stock of the product in the Firestore database
    await FirebaseFirestore.instance
        .collection('stock_updates')
        .doc(productId)
        .update({'updatedStock': newStock});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Updates'),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: stockUpdatesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<DocumentSnapshot> stockUpdates = snapshot.data ?? [];
            return ListView.builder(
              itemCount: stockUpdates.length,
              itemBuilder: (context, index) {
                DocumentSnapshot update = stockUpdates[index];
                return ListTile(
                  title: Text(update['productName']),
                  subtitle: Text('Current Stock: ${update['updatedStock']}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Open a dialog to input the new stock quantity
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Update Stock'),
                          content: TextField(
                            controller: _newStockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'New Stock Quantity'),
                            onChanged: (value) {
                              // You can add validation if needed
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                int newStock = int.tryParse(_newStockController.text.trim()) ?? 0;
                                _updateStock(update.id, newStock);
                                Navigator.pop(context);
                              },
                              child: Text('Update'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Update Stock'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _newStockController.dispose();
    super.dispose();
  }
}
