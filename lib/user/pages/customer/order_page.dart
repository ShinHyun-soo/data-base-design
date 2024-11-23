import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';

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
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load products')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String formatPhoneNumber(String phone) {
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.length >= 11) {
      return '${phone.substring(0, 3)}-${phone.substring(3, 7)}-${phone.substring(7, 11)}';
    }
    return phone;
  }

  Future<bool> validateZipCode(String zipCode) async {
    try {
      final response = await http.post(
        Uri.parse(API.validateZipCode),
        body: {'zip_code': zipCode},
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['success'];
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> submitOrder() async {
  if (_formKey.currentState!.validate()) {
    final formattedPhone = formatPhoneNumber(_phoneController.text);
    debugPrint('Formatted phone: $formattedPhone');
    debugPrint('Validating zip code: ${_zipCodeController.text}');
    final zipCodeValid = await validateZipCode(_zipCodeController.text);

    if (!zipCodeValid) {
      debugPrint('Invalid zip code');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Zip Code')),
      );
      return;
    }

    debugPrint('Submitting order with product ID: $selectedProductId');
    final response = await http.post(
      Uri.parse(API.addOrderWithReceiver),
      body: {
        'receiver_name': _nameController.text,
        'receiver_phone': formattedPhone,
        'receiver_address': _addressController.text,
        'receiver_zip_code': _zipCodeController.text,
        'product_id': selectedProductId!,
      },
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      debugPrint('Parsed JSON: $jsonResponse');

      if (jsonResponse['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully')),
        );
        widget.onOrderSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create order')),
      );
    }
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
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Receiver Name'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter receiver name' : null,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Receiver Phone'),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      onChanged: (value) {
                        final formatted = formatPhoneNumber(value);
                        _phoneController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      },
                      validator: (value) {
                        final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
                        if (value == null || value.isEmpty || !phoneRegex.hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Receiver Address'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter receiver address' : null,
                    ),
                    TextFormField(
                      controller: _zipCodeController,
                      decoration: const InputDecoration(labelText: 'Receiver Zip Code'),
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
                    ElevatedButton(
                      onPressed: submitOrder,
                      child: const Text('Submit Order'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
