import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';

class DetailOrderPage extends StatefulWidget {
  final int orderId;

  const DetailOrderPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _DetailOrderPageState createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  Map<String, dynamic>? orderDetails;
  Map<String, dynamic>? inquiryDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final response = await http.post(
        Uri.parse(API.getOrderDetails),
        body: {'order_id': widget.orderId.toString()},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            orderDetails = jsonResponse['data'];
            isLoading = false;
          });
          fetchInquiryDetails();
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch order details')),
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

  Future<void> fetchInquiryDetails() async {
  try {
    final response = await http.post(
      Uri.parse(API.getInquiryDetails),
      body: {'order_id': widget.orderId.toString()},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        setState(() {
          inquiryDetails = jsonResponse['data'];
        });
        debugPrint('Fetched Inquiry Details: $inquiryDetails');
      } else {
        debugPrint('Failed to fetch inquiry details: ${jsonResponse['message']}');
        inquiryDetails = null;
      }
    } else {
      debugPrint('Failed to fetch inquiry details. Status code: ${response.statusCode}');
      inquiryDetails = null;
    }
  } catch (e) {
    debugPrint('Error fetching inquiry details: $e');
    inquiryDetails = null;
  }
}


  Future<void> deleteInquiry(int inquiryId) async {
    try {
      final response = await http.post(
        Uri.parse(API.deleteInquiry),
        body: {'inquiry_id': inquiryId.toString()},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
          setState(() {
            inquiryDetails = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete inquiry')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> updateInquiry(int inquiryId, String newComment) async {
    try {
      final response = await http.post(
        Uri.parse(API.changeInquiry),
        body: {
          'inquiry_id': inquiryId.toString(),
          'inquiry_comment': newComment,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
          fetchInquiryDetails(); // Fetch updated details
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update inquiry')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showEditDialog() {
  if (inquiryDetails == null || inquiryDetails!['inquiry_id'] == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inquiry ID is not available')),
    );
    return;
  }

  final TextEditingController _editController = TextEditingController(
    text: inquiryDetails!['inquiry_comment'],
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Inquiry'),
      content: TextField(
        controller: _editController,
        decoration: const InputDecoration(
          labelText: 'Inquiry Comment',
        ),
        maxLines: 5,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (inquiryDetails!['inquiry_id'] != null) {
              updateInquiry(
                inquiryDetails!['inquiry_id'] as int,
                _editController.text,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid Inquiry ID')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderDetails == null
              ? const Center(child: Text('No details available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text('User Name: ${orderDetails!['user_name'] ?? "Not Available"}'),
                      Text('Receiver Name: ${orderDetails!['receiver_name']}'),
                      Text('Phone: ${orderDetails!['receiver_phone']}'),
                      Text('Address: ${orderDetails!['receiver_address']}'),
                      Text('Zip Code: ${orderDetails!['receiver_zip_code']}'),
                      Text('Product: ${orderDetails!['product_name']}'),
                      Text('Order Date: ${orderDetails!['order_date']}'),
                      Text('Delivery Date: ${orderDetails!['availability_date']}'),
                      const SizedBox(height: 16),
                      Text('Delivery Company: ${orderDetails!['company_name'] ?? "Not Available"}'),
                      Text('Delivery Personnel: ${orderDetails!['personnel_name'] ?? "Not Available"}'),
                      Text(
                        'Current State: ${orderDetails!['current_state'] == 0 ? "In Transit" : "Delivered"}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: orderDetails!['current_state'] == 0
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                      if (inquiryDetails != null) ...[
                        const Divider(),
                        Text(
                          'Inquiry Status:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          inquiryDetails!['problem_state'] == 1
                              ? 'Resolved'
                              : 'Not Resolved',
                          style: TextStyle(
                            color: inquiryDetails!['problem_state'] == 1
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${inquiryDetails!['inquiry_comment'] ?? "No comment available"}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: inquiryDetails!['problem_state'] == 1
                                  ? null // 해결된 문의는 삭제 불가
                                  : () => deleteInquiry(inquiryDetails!['inquiry_id']),
                              icon: Icon(Icons.delete, color: inquiryDetails!['problem_state'] == 1 ? Colors.grey : Colors.red),
                            ),
                            IconButton(
                              onPressed: inquiryDetails!['problem_state'] == 1
                                  ? null // 해결된 문의는 수정 불가
                                  : showEditDialog,
                              icon: Icon(Icons.edit, color: inquiryDetails!['problem_state'] == 1 ? Colors.grey : Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
