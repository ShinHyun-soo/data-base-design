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

  // `product_id`를 문자열로 변환
  selectedProductId = widget.orderData['product_id']?.toString();

  // 디버그 로그 추가
  debugPrint('Order Data: ${widget.orderData}');
  debugPrint('Initial Selected Product ID: $selectedProductId');

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

        // 선택된 제품 ID가 유효한지 확인
        if (!products.any((product) => product['product_id'].toString() == selectedProductId)) {
          debugPrint(
              'Selected Product ID $selectedProductId not found in products. Resetting to null.');
          selectedProductId = null; // 선택된 제품이 유효하지 않다면 null로 설정
        } else {
          debugPrint('Selected Product ID $selectedProductId is valid.');
        }
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

  Future<void> updateOrder() async {
  if (_formKey.currentState!.validate()) {
    final formattedPhone = formatPhoneNumber(_phoneController.text);
    debugPrint('Formatted phone: $formattedPhone');
    debugPrint('Selected product ID: $selectedProductId');
    debugPrint('Updating order with order ID: ${widget.orderData['order_id']}');

    final response = await http.post(
      Uri.parse(API.updateOrder),
      body: {
        'order_id': widget.orderData['order_id'].toString(),
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
        // Parcel 업데이트 로직 추가
        await updateParcelPersonnel();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order updated successfully')),
        );
        Navigator.pop(context, true); // 성공 시 true 반환
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order')),
      );
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

    debugPrint('Update Parcel Personnel Response: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (!jsonResponse['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update parcel personnel')),
      );
    }
  } catch (e) {
    debugPrint('Error updating parcel personnel: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
                        final isPreviouslySelected =
                            product['product_id'].toString() == widget.orderData['product_id'].toString();

                        return DropdownMenuItem<String>(
                          value: product['product_id'].toString(),
                          child: Text(
                            '${product['product_name']} (Factory: ${product['factory_name']}, Stock: $stock)',
                            style: TextStyle(
                              color: isPreviouslySelected
                                  ? Colors.blue // 기존 선택된 제품은 파란색으로 표시
                                  : (stock == 0 ? Colors.red : Colors.black), // 재고가 없으면 빨간색, 그 외는 검정색
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
                      onPressed: updateOrder,
                      child: const Text('Update Order'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
