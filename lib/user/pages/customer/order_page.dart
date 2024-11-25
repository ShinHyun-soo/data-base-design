import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  final Function onOrderSuccess;

  const OrderPage({Key? key, required this.onOrderSuccess}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  String? selectedProductId;
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(API.getProducts));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          products = jsonResponse['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showSnackBar('Failed to load products', isError: true);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('user_id');
    if (userIdString != null) {
      return int.tryParse(userIdString);
    }
    return null;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> submitOrder() async {
    if (_formKey.currentState!.validate()) {
      final userId = await getUserId();
      if (userId == null) {
        _showSnackBar('User ID not found. Please log in again.', isError: true);
        return;
      }

      final response = await http.post(
        Uri.parse(API.addOrderWithReceiver),
        body: {
          'receiver_name': _nameController.text,
          'receiver_phone': _phoneController.text,
          'receiver_address': _addressController.text,
          'receiver_zip_code': _zipCodeController.text,
          'product_id': selectedProductId!,
          'user_id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          _showSnackBar('Order created successfully');
          widget.onOrderSuccess();
          Navigator.pop(context);
        } else {
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to create order', isError: true);
      }
    }
  }

  String _formatPhoneNumber(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length >= 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7, 11)}';
    } else if (digits.length >= 7) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    } else if (digits.length >= 4) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else {
      return digits;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Page'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'Receiver Name',
                      icon: Icons.person,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter receiver name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      labelText: 'Receiver Phone',
                      icon: Icons.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      onChanged: (value) {
                        final formattedPhone = _formatPhoneNumber(value);
                        _phoneController.value = TextEditingValue(
                          text: formattedPhone,
                          selection: TextSelection.collapsed(offset: formattedPhone.length),
                        );
                      },
                      validator: (value) {
                        final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
                        if (value == null || value.isEmpty || !phoneRegex.hasMatch(value)) {
                          return 'Please enter a valid phone number (e.g., 010-1234-5678)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      labelText: 'Receiver Address',
                      icon: Icons.location_on,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter receiver address'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _zipCodeController,
                      labelText: 'Receiver Zip Code',
                      icon: Icons.local_post_office,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      validator: (value) {
                        final zipCodeRegex = RegExp(r'^\d{5}$');
                        if (value == null || value.isEmpty || !zipCodeRegex.hasMatch(value)) {
                          return 'Please enter a valid zip code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedProductId,
                      onChanged: (value) {
                        setState(() {
                          selectedProductId = value;
                        });
                      },
                      items: products.map<DropdownMenuItem<String>>((product) {
                        final stock = int.tryParse(product['stock'].toString()) ?? 0;
                        return DropdownMenuItem<String>(
                          value: product['product_id'].toString(),
                          child: Text(
                            '${product['product_name']} (Stock: $stock)',
                            style: TextStyle(
                              color: stock == 0 ? Colors.red : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Product',
                      ),
                      validator: (value) => value == null ? 'Please select a product' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: submitOrder,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Order'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
