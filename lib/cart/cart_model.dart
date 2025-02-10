import 'dart:typed_data';

class CartItem {
  final int medicineId;
  final String name;
  final double price;
  int quantity;
  int remainingQuantity; // Total available quantity
  final Uint8List? image;

  CartItem({
    required this.medicineId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.remainingQuantity,
    this.image,
  });
}