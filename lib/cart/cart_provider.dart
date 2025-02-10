import 'package:flutter/foundation.dart';

import 'cart_model.dart';
import 'package:flutter/material.dart';
import '../database/pharmacy_db_helper.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  final PharmacyDatabaseHelper dbHelper = PharmacyDatabaseHelper();

  List<CartItem> get cartItems => _cartItems;

  Future<void> addToCart(Map<String, dynamic> medicine) async {
    final currentMedicine = await dbHelper.getMedicineById(medicine['id']);

    for (var cartItem in _cartItems) {
      if (cartItem.medicineId == medicine['id']) {
        if (cartItem.quantity + 1 <= currentMedicine?['quantity']) {
          cartItem.quantity++;
          notifyListeners();
        }
        return;
      }
    }

    if (currentMedicine?['quantity'] > 0) {
      final cartItem = CartItem(
        medicineId: medicine['id'],
        name: medicine['name'],
        price: medicine['price'],
        quantity: 1,
        remainingQuantity: currentMedicine!['quantity'],
        image: medicine['image'],
      );
      _cartItems.add(cartItem);
      notifyListeners();
    }
  }

  void removeFromCart(int medicineId) {
    _cartItems.removeWhere((item) => item.medicineId == medicineId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double getTotalPrice() {
    return _cartItems.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  Future<bool> processOrder() async {
    try {
      final totalAmount = getTotalPrice();
      final orderId = await dbHelper.createOrder(totalAmount);

      final orderItems = _cartItems.map((item) => {
        'medicine_id': item.medicineId,
        'quantity': item.quantity,
        'price': item.price,
      }).toList();

      await dbHelper.addOrderItems(orderId, orderItems);
      clearCart();
      return true;
    } catch (e) {
      print('Order processing error: $e');
      return false;
    }
  }
}