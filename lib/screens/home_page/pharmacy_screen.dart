import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../constants.dart';
import '../../../database/pharmacy_db_helper.dart';
import '../../../cart/cart_screen.dart';

class UserPharmacyScreen extends StatefulWidget {
  @override
  _UserPharmacyScreenState createState() => _UserPharmacyScreenState();
}

class _UserPharmacyScreenState extends State<UserPharmacyScreen> {
  final PharmacyDatabaseHelper dbHelper = PharmacyDatabaseHelper();

  void _showMedicineDetails(Map<String, dynamic> medicine) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine image
            Center(
              child: medicine['image'] != null
                  ? Image.memory(medicine['image'], height: 200)
                  : Icon(Icons.medical_services, size: 200),
            ),
            Text(
              medicine['name'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.teal,
              ),
            ),
            SizedBox(height: 10),
            Text(
              medicine['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Rs. ${medicine['price']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.lightBlue,
              ),
            ),
            SizedBox(height: 10),
            Text('Available: ${medicine['quantity']} units'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: medicine['quantity'] > 0
                  ? () async {
                // Add to cart logic
                await dbHelper.decrementMedicineQuantity(medicine['id'],medicine['quantity']);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen())
                );
              }
                  : null,
              child: Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: medicine['quantity'] > 0
                    ? AppColors.teal
                    : Colors.grey,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pharmacy',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.getAllMedicines(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final medicine = snapshot.data![index];
                        return GestureDetector(
                          onTap: () => _showMedicineDetails(medicine),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: medicine['image'] != null
                                      ? Image.memory(medicine['image'], fit: BoxFit.cover)
                                      : Icon(Icons.medical_services, size: 100),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        medicine['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.teal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Rs. ${medicine['price']}',
                                        style: TextStyle(
                                          color: AppColors.lightBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
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
}