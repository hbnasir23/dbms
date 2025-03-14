import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'purchase_history_provider.dart';
import 'purchase_detail.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final purchaseHistoryProvider = Provider.of<PurchaseHistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase History"),
      ),
      body: purchaseHistoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : purchaseHistoryProvider.purchaseHistory.isEmpty
          ? const Center(child: Text('No purchase history found.'))
          : ListView.builder(
        itemCount: purchaseHistoryProvider.purchaseHistory.length,
        itemBuilder: (context, index) {
          final purchase = purchaseHistoryProvider.purchaseHistory[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text('Total Amount: Rs. ${purchase['total_amount']}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Date: ${DateTime.parse(purchase['timestamp']).toLocal()}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseDetailScreen(purchase: purchase),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Refreshing purchase history...");
          purchaseHistoryProvider.fetchPurchaseHistory();
        },
        child: Icon(Icons.refresh),
      ),

    );
  }
}
