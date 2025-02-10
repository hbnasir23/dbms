import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../constants.dart';
import '../../../database/pharmacy_db_helper.dart';
import '../../../cart/cart_model.dart';
import '../../../cart/cart_provider.dart';
import '../../../cart/cart_screen.dart';
import 'package:provider/provider.dart';

class AdminPharmacyScreen extends StatefulWidget {
  @override
  _AdminPharmacyScreenState createState() => _AdminPharmacyScreenState();
}

class _AdminPharmacyScreenState extends State<AdminPharmacyScreen> {
  final PharmacyDatabaseHelper dbHelper = PharmacyDatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicineBottomSheet(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Medicines List',
                    style: TextStyle(
                      fontSize: AppConstants.deviceWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    height: AppConstants.deviceHeight * 0.08,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.getAllMedicines(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No medicines found'));
                    }
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final medicine = snapshot.data![index];
                        return _buildMedicineCard(medicine);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return GestureDetector(
      onTap: () => _showMedicineDetails(medicine),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.teal[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal[100],
                child: medicine['image'] != null
                    ? ClipOval(
                  child: Image.memory(
                    medicine['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.medical_services, size: 40, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  medicine['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs. ${medicine['price']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.teal[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              ElevatedButton(
                onPressed: () {
                  _showAddToCartBottomSheet(medicine);
                },
                child: Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showAddToCartBottomSheet(Map<String, dynamic> medicine) {
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add ${medicine['name']} to Cart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),
                      Text(
                        quantity.toString(),
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (quantity < medicine['quantity']) {
                            setState(() {
                              quantity++;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Add to cart logic
                      final cartItem = CartItem(
                        medicineId: medicine['id'],
                        name: medicine['name'],
                        price: medicine['price'],
                        quantity: quantity,
                        image: medicine['image'], remainingQuantity: medicine[quantity],
                      );

                      // Assuming you're using Provider for state management
                      Provider.of<CartProvider>(context, listen: false)
                          .addToCart(cartItem as Map<String, dynamic>);

                      Navigator.pop(context);
                      _showCartBottomSheet();
                    },
                    child: Text('Add to Cart'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Your Cart',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProvider.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartProvider.cartItems[index];
                        return ListTile(
                          leading: cartItem.image != null
                              ? Image.memory(cartItem.image!, width: 50, height: 50)
                              : Icon(Icons.medical_services),
                          title: Text(cartItem.name),
                          subtitle: Text('Rs. ${cartItem.price} x ${cartItem.quantity}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              cartProvider.removeFromCart(cartItem.medicineId);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    'Total: Rs. ${cartProvider.getTotalPrice().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _confirmOrder(cartProvider);
                    },
                    child: Text('Confirm Order'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // Order Confirmation Method
  void _confirmOrder(CartProvider cartProvider) async {
    // Validate order
    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    // Process order and update database
    for (var item in cartProvider.cartItems) {
      // Fetch current medicine details
      final medicine = await dbHelper.getMedicineById(item.medicineId);

      // Validate stock
      if (medicine?['quantity'] < item.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient stock for ${item.name}')),
        );
        return;
      }

      // Update quantity in database
      await dbHelper.decrementMedicineQuantity(
          item.medicineId,
          medicine?['quantity'] - item.quantity
      );
    }

    // Generate receipt
    _showReceiptBottomSheet(cartProvider);

    // Clear cart
    cartProvider.clearCart();
  }

  // Receipt Bottom Sheet
  void _showReceiptBottomSheet(CartProvider cartProvider) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Order Receipt',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ...cartProvider.cartItems.map((item) => ListTile(
                title: Text(item.name),
                subtitle: Text('${item.quantity} x Rs. ${item.price}'),
                trailing: Text('Rs. ${item.quantity * item.price}'),
              )).toList(),
              Divider(),
              Text(
                'Total: Rs. ${cartProvider.getTotalPrice().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
  void _showMedicineDetails(Map<String, dynamic> medicine) {
    showMaterialModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Medicine Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Medicine image
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: ClipOval(
                  child: medicine['image'] != null
                      ? Image.memory(
                    medicine['image'],
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.teal[50],
                    child: const Icon(
                      Icons.medical_services,
                      size: 80,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.teal),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddMedicineBottomSheet(medicine: medicine);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(medicine['id']),
                ),
              ],
            ),
            _buildDetailRow('Name', medicine['name']),
            _buildDetailRow('Description', medicine['description']),
            _buildDetailRow('Price', 'Rs. ${medicine['price']}'),
            _buildDetailRow('Quantity', '${medicine['quantity']} units'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMedicineBottomSheet({Map<String, dynamic>? medicine}) {
    final TextEditingController nameController = TextEditingController(
      text: medicine?['name'] ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: medicine?['description'] ?? '',
    );
    final TextEditingController priceController = TextEditingController(
      text: medicine?['price']?.toString() ?? '',
    );
    final TextEditingController quantityController = TextEditingController(
      text: medicine?['quantity']?.toString() ?? '',
    );
    File? imageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                medicine == null ? 'Add Medicine' : 'Edit Medicine',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(imageFile!, fit: BoxFit.cover),
                  )
                      : medicine?['image'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      medicine!['image'],
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(
                    Icons.add_a_photo,
                    color: Colors.teal,
                  ),
                ),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Medicine Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final medicineData = {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'price': double.parse(priceController.text),
                    'quantity': int.parse(quantityController.text),
                    'image': imageFile != null
                        ? await imageFile!.readAsBytes()
                        : medicine?['image'],
                  };

                  if (medicine == null) {
                    await dbHelper.insertMedicine(medicineData);
                  } else {
                    await dbHelper.updateMedicine(
                      medicine['id'],
                      medicineData,
                    );
                  }

                  Navigator.pop(context);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {});
                  });

                },
                child: Text(medicine == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int medicineId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this medicine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await dbHelper.deleteMedicine(medicineId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              setState(() {}); // Refresh the list
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}