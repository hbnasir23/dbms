import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'cart/cart_provider.dart';
import 'receipt_screen.dart';
import '../../../../globals.dart';
import '../../../../constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressPaymentScreen extends StatefulWidget {
  const AddressPaymentScreen({super.key});

  @override
  _AddressPaymentScreenState createState() => _AddressPaymentScreenState();
}

class _AddressPaymentScreenState extends State<AddressPaymentScreen> {
  final TextEditingController _addressController = TextEditingController();
  LatLng? _selectedLocation;
  String _paymentMethod = 'COD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirm Address & Payment',
          style: TextStyle(
            color: AppColors.teal,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.teal,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(27.7172, 85.3240), // Default location (Kathmandu)
                  initialZoom: 13.0, // Set an initial zoom level
                  onTap: (tapPosition, point) {
                    setState(() {
                      _selectedLocation = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation!,
                          child: const Icon(Icons.location_on, color: Colors.red), // Use `child` instead of `builder`
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Enter your address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioListTile(
              title: const Text('Cash On Delivery (COD)'),
              value: 'COD',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value.toString();
                });
              },
            ),
            RadioListTile(
              title: const Text('Card Payment'),
              value: 'Card',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value.toString();
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_selectedLocation == null || _addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a location and enter your address')),
                  );
                  return;
                }

                if (_paymentMethod == 'Card') {
                  // Implement Stripe payment gateway here
                  // For now, we'll just show a SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Card payment selected. Integrate Stripe here.')),
                  );
                  return;
                }

                // Proceed to checkout
                final cart = Provider.of<CartProvider>(context, listen: false);
                final userEmail = loggedInEmail;
                if (userEmail != null) {
                  int? userId = await getUserIdByEmail(userEmail);
                  if (userId != null) {
                    _checkoutProcess(context, userId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to fetch user ID')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not logged in')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.teal,
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> getUserIdByEmail(String email) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.from('users').select('id').eq('email', email).single();
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
        final currentItem = await supabase
            .from('pharmacy')
            .select('quantity')
            .eq('id', cartItem.id)
            .single();

        int currentQuantity = currentItem['quantity'];

        if (currentQuantity < cartItem.quantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Insufficient stock for ${cartItem.name}')),
          );
          return;
        }

        await supabase
            .from('pharmacy')
            .update({'quantity': currentQuantity - cartItem.quantity}).eq('id', cartItem.id);
      }

      final userEmail = loggedInEmail;
      int? userId = await getUserIdByEmail(userEmail!);

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

      final List<CartItem> itemsCopy = List.from(cart.items);
      final double totalAmount = cart.totalAmount;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            items: itemsCopy,
            totalAmount: totalAmount,
          ),
        ),
      ).then((_) {
        cart.clearCart();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    }
  }
}