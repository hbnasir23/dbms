import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_provider.dart';
import '../receipt_screen.dart';
import '../../../../globals.dart';
import '../../../../constants.dart';
import '../address_payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(
            color: AppColors.teal, 
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.teal, //
        ),
      ),

      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      leading: Image.network(
                        item.photo,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.medication);
                        },
                      ),
                      title: Text(item.name),
                      subtitle: Text('Rs. ${item.price}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (item.quantity > 1) {
                                cart.updateQuantity(item.id, item.quantity - 1);
                              } else {
                                cart.removeFromCart(item.id);
                              }
                            },
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              final available = await checkStockAvailability(
                                  item.id, item.quantity + 1);
                              if (available) {
                                cart.updateQuantity(item.id, item.quantity + 1);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Out of Stock'),
                                      content:
                                          Text('${item.name} is out of stock.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed:
                    Provider.of<CartProvider>(context, listen: false).clearCart,
                child: const Text(
                  'Clear Cart',
                  style: TextStyle(
                    color: AppColors.teal,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Total: Rs. ${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Payment Method: Cash On Delivery (COD)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressPaymentScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppColors.teal,
                        ),
                        child: const Text(
                          'Confirm Address & Payment Method',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<int?> getUserIdByEmail(String email) async {
    final supabase = Supabase.instance.client;
    try {
      final response =
          await supabase.from('users').select('id').eq('email', email).single();

      return response['id'];
    } catch (e) {
      return null;
    }
  }

  void _checkoutProcess(BuildContext context, int userId) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final supabase = Supabase.instance.client;

    try {
      // Batch update for quantity
      for (var cartItem in cart.items) {
        // Fetch current quantity
        final currentItem = await supabase
            .from('pharmacy')
            .select('quantity')
            .eq('id', cartItem.id)
            .single();

        int currentQuantity = currentItem['quantity'];

        // Check if sufficient stock
        if (currentQuantity < cartItem.quantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Insufficient stock for ${cartItem.name}'),
            ),
          );
          return;
        }

        // Manual quantity update
        await supabase
            .from('pharmacy')
            .update({'quantity': currentQuantity - cartItem.quantity}).eq(
                'id', cartItem.id);
      }
      final userEmail = loggedInEmail;
      int? userId = await getUserIdByEmail(userEmail!);

      // Save purchase history
      await supabase.from('purchase_history').insert({
        'user_id': userId,
        'items': cart.items
            .map((item) => {
                  'id': item.id,
                  'name': item.name,
                  'quantity': item.quantity,
                  'price': item.price,
                })
            .toList(),
        'total_amount': cart.totalAmount,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Create a copy of the cart items for the receipt screen
      final List<CartItem> itemsCopy = List.from(cart.items);
      final double totalAmount = cart.totalAmount;

      // Navigate to receipt screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            items: itemsCopy,
            totalAmount: totalAmount,
          ),
        ),
      ).then((_) {
        // Clear cart AFTER navigation is complete
        cart.clearCart();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    }
  }

  Future<bool> checkStockAvailability(int itemId, int requestedQuantity) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('pharmacy')
          .select('quantity')
          .eq('id', itemId)
          .single();

      return response['quantity'] >= requestedQuantity;
    } catch (e) {
      return false;
    }
  }
}
