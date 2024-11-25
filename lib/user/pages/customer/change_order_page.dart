import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';

class ChangeOrderPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const ChangeOrderPage({Key? key, required this.orderData}) : super(key: key);

  @override
  _ChangeOrderPageState createState() => _ChangeOrderPageState();
}

class _ChangeOrderPageState extends State<ChangeOrderPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _zipCodeController;

  String? selectedProductId;
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.orderData['receiver_name']);
    _phoneController = TextEditingController(text: widget.orderData['receiver_phone']);
    _addressController = TextEditingController(text: widget.orderData['receiver_address']);
    _zipCodeController = TextEditingController(text: widget.orderData['receiver_zip_code']);

    fetchProducts().then((_) {
      final productName = widget.orderData['product_name'];
      final matchedProduct = products.firstWhere(
        (product) => product['product_name'] == productName,
        orElse: () => null,
      );

      setState(() {
        selectedProductId = matchedProduct?['product_id']?.toString();
      });
    });
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
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

  void _onPhoneNumberChanged(String value) {
    final previousText = _phoneController.text;
    final previousSelection = _phoneController.selection;

    final formattedText = _formatPhoneNumber(value);

    // 현재 커서 위치 계산
    final offset = previousSelection.baseOffset +
        (formattedText.length - previousText.length);

    _phoneController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: offset.clamp(0, formattedText.length),
      ),
    );
  }

  Future<void> updateOrder() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse(API.updateOrder),
        body: {
          'order_id': widget.orderData['order_id'].toString(),
          'receiver_name': _nameController.text,
          'receiver_phone': _phoneController.text,
          'receiver_address': _addressController.text,
          'receiver_zip_code': _zipCodeController.text,
          'product_id': selectedProductId!,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          await updateParcelPersonnel();
          _showSnackBar('Order updated successfully');
          Navigator.pop(context, true);
        } else {
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to update order', isError: true);
      }
    }
  }

  Future<void> updateParcelPersonnel() async {
    try {
      final response = await http.post(
        Uri.parse(API.updateParcelPersonnel),
        body: {
          'order_id': widget.orderData['order_id'].toString(),
          'receiver_zip_code': _zipCodeController.text,
        },
      );

      if (response.statusCode != 200) {
        _showSnackBar('Failed to update parcel personnel', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter receiver name' : null,
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
                      onChanged: _onPhoneNumberChanged,
                      validator: (value) {
                        final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
                        if (value == null || value.isEmpty || !phoneRegex.hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      labelText: 'Receiver Address',
                      icon: Icons.location_on,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter receiver address' : null,
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
                        final isPreviouslySelected =
                            product['product_id'].toString() == selectedProductId;

                        return DropdownMenuItem<String>(
                          value: product['product_id'].toString(),
                          child: Text(
                            '${product['product_name']} (Factory: ${product['factory_name']}, Stock: $stock)',
                            style: TextStyle(
                              color: isPreviouslySelected
                                  ? Colors.blue
                                  : (stock == 0 ? Colors.red : Colors.black),
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
                      onPressed: updateOrder,
                      icon: const Icon(Icons.update),
                      label: const Text('Update Order'),
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
    ValueChanged<String>? onChanged,
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
