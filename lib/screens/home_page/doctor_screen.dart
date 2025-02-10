import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../database/doctor_db_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final DoctorDatabaseHelper _dbHelper = DoctorDatabaseHelper();
  List<Map<String, dynamic>> _doctors = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final doctors = await _dbHelper.getAllDoctors();
    setState(() {
      _doctors = doctors;
    });
  }

  void _showDoctorDetails(Map<String, dynamic> doctor) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => Material(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Doctor Image
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75),
                      border: Border.all(color: Colors.teal, width: 2),
                      image: doctor['photo'] != null
                          ? DecorationImage(
                        image: MemoryImage(doctor['photo']),
                        fit: BoxFit.cover,

                      )
                          : DecorationImage(
                        image: AssetImage('assets/images/default_doctor.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Doctor Details
                Text(
                  doctor['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Specialization: ${doctor['specialization']}",
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                SizedBox(height: 10),
                Text(
                  "Area: ${doctor['area']}",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 5),
                Text(
                  "Hospital/Clinic: ${doctor['hospital']}",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 10),
                Text(
                  "Consultation Fees: Rs. ${doctor['fees']}",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Spacer(),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final phone = doctor['phone']?.toString().replaceAll(' ', '');
                        if (phone != null && phone.isNotEmpty) {
                          final phoneUrl = 'tel:$phone';
                          if (await canLaunch(phoneUrl)) {
                            await launch(phoneUrl);
                          } else {
                            throw 'Could not open the dialer.';
                          }
                        } else {
                          throw 'Phone number is invalid or missing.';
                        }
                      },
                      icon: Icon(Icons.phone, color: Colors.white),
                      label: Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Book appointment functionality
                      },
                      child: Text('Book Appointment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(

        children: [
          SizedBox(height: AppConstants.deviceHeight*.055),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Doctors',
                  style: TextStyle(
                    fontSize: AppConstants.deviceWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // Logo on the right
                Image.asset(
                  'assets/images/logo.png', // Update with your logo path

                  height: AppConstants.deviceHeight * 0.08,
                ),
              ],
            ),
          ),
          // Body content
          _doctors.isEmpty
              ? Center(child: Text('No Doctors available', style: TextStyle(fontSize: 18, color: Colors.black87)))
              : Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Keep this ratio
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _doctors.length,
              itemBuilder: (context, index) {
                final doctor = _doctors[index];
                return GestureDetector(
                  onTap: () => _showDoctorDetails(doctor),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Doctor Image
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              image: doctor['photo'] != null
                                  ? DecorationImage(
                                image: MemoryImage(doctor['photo']),
                                fit: BoxFit.cover,
                              )
                                  : DecorationImage(
                                image: AssetImage('assets/images/default_doctor.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        // Doctor Info
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  doctor['specialization'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  doctor['area'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
