import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cartItems[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: Text('Rs. ${item.price * item.quantity}'),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await cartProvider.processOrder();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order Processed Successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order Processing Failed')),
                    );
                  }
                },
                child: Text('Place Order'),
              ),
            ],
          );
        },
      ),
    );
  }
}