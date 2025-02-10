import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../database/doctor_db_helper.dart';
import '../../../constants.dart';

class AddDoctorsScreen extends StatefulWidget {
  final Map<String, dynamic>? doctor;

  const AddDoctorsScreen({Key? key, this.doctor}) : super(key: key);

  @override
  State<AddDoctorsScreen> createState() => _AddDoctorsScreenState();
}

class _AddDoctorsScreenState extends State<AddDoctorsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _feesController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _nameController.text = widget.doctor!['name'];
      _phoneController.text = widget.doctor!['phone'];
      _specializationController.text = widget.doctor!['specialization'];
      _areaController.text = widget.doctor!['area'];
      _hospitalController.text = widget.doctor!['hospital'];
      _feesController.text = widget.doctor!['fees'].toString();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addDoctor(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final dbHelper = DoctorDatabaseHelper();
        final doctor = {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'specialization': _specializationController.text,
          'area': _areaController.text,
          'hospital': _hospitalController.text,
          'fees': double.tryParse(_feesController.text) ?? 0.0,
          'photo': _imageFile != null ? await _imageFile!.readAsBytes() : null,
        };

        final db = await dbHelper.database;

        if (widget.doctor == null) {
          // Adding a new doctor
          await db.insert('doctors', doctor);
          _showSuccessMessage(context, 'Doctor added successfully!');
        } else {
          // Updating an existing doctor
          await db.update(
              'doctors',
              doctor,
              where: 'id = ?',
              whereArgs: [widget.doctor!['id']]
          );
          _showSuccessMessage(context, 'Doctor updated successfully!');
        }

        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

// Helper method to show success message
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        widget.doctor == null
                            ? 'Add New Doctor'
                            : 'Edit Doctor',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: AppConstants.deviceHeight*.18,
                        width: AppConstants.deviceWidth*.18,
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.add_a_photo,
                                size: 50, color: Colors.grey),
                      ),
                    ),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Doctor Name',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter doctor name' : null,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter phone number' : null,
                    ),
                    _buildTextField(
                      controller: _specializationController,
                      label: 'Specialization',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter specialization' : null,
                    ),
                    _buildTextField(
                      controller: _areaController,
                      label: 'Area',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter area' : null,
                    ),
                    _buildTextField(
                      controller: _hospitalController,
                      label: 'Hospital/Clinic',
                      validator: (value) => value!.isEmpty
                          ? 'Please enter hospital/clinic'
                          : null,
                    ),
                    _buildTextField(
                      controller: _feesController,
                      label: 'Consultation Fees',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter fees';
                        if (double.tryParse(value) == null)
                          return 'Please enter valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _addDoctor(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        widget.doctor == null ? 'Add Doctor' : 'Save Changes',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _areaController.dispose();
    _hospitalController.dispose();
    _feesController.dispose();
    super.dispose();
  }
}
