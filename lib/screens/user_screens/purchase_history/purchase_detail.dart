import 'package:flutter/material.dart';

class PurchaseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> purchase;

  const PurchaseDetailScreen({Key? key, required this.purchase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List items = purchase['items'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Details')),
      body: Column(
        children: [
          ListTile(
            title: Text('Total Amount: Rs. ${purchase['total_amount']}'),
            subtitle: Text('Date: ${DateTime.parse(purchase['timestamp']).toLocal()}'),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Quantity: ${item['quantity']} - Price: Rs. ${item['price']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
