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
    setState(() => isLoading = true);
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
          });
          fetchInquiryDetails();
        } else {
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to fetch order details', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error fetching order details: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
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
        }
      }
    } catch (e) {
      _showSnackBar('Error fetching inquiry details: $e', isError: true);
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
          _showSnackBar('Inquiry deleted successfully');
          setState(() {
            inquiryDetails = null;
          });
        } else {
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to delete inquiry', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error deleting inquiry: $e', isError: true);
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
          _showSnackBar('Inquiry updated successfully');
          fetchInquiryDetails();
        } else {
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to update inquiry', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error updating inquiry: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  void _showEditDialog() {
    if (inquiryDetails == null || inquiryDetails!['inquiry_id'] == null) {
      _showSnackBar('Inquiry ID not available', isError: true);
      return;
    }

    final _editController =
        TextEditingController(text: inquiryDetails!['inquiry_comment']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Inquiry'),
        content: TextField(
          controller: _editController,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Inquiry Comment',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              updateInquiry(
                inquiryDetails!['inquiry_id'] as int,
                _editController.text,
              );
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
        title: const Text('상세 주문'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderDetails == null
              ? const Center(child: Text('No details available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      _buildSection('User Name', orderDetails!['user_name']),
                      _buildSection('Receiver Name', orderDetails!['receiver_name']),
                      _buildSection('Phone', orderDetails!['receiver_phone']),
                      _buildSection('Address', orderDetails!['receiver_address']),
                      _buildSection('Zip Code', orderDetails!['receiver_zip_code']),
                      _buildSection('Product', orderDetails!['product_name']),
                      _buildSection('Order Date', orderDetails!['order_date']),
                      _buildSection('Delivery Date', orderDetails!['availability_date']),
                      _buildSection('Delivery Company', orderDetails!['company_name']),
                      _buildSection(
                        'Current State',
                        orderDetails!['current_state'] == 0 ? 'In Transit' : 'Delivered',
                        highlight: true,
                      ),
                      if (inquiryDetails != null) ...[
                        const Divider(),
                        const Text(
                          'Inquiry Details',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        _buildSection('Problem State', inquiryDetails!['problem_state'] == 1 ? 'Resolved' : 'Not Resolved'),
                        _buildSection('Comment', inquiryDetails!['inquiry_comment']),
                        _buildSection('Report Comment', inquiryDetails!['report_comment']),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: inquiryDetails!['problem_state'] == 1
                                  ? null
                                  : () => deleteInquiry(inquiryDetails!['inquiry_id']),
                              icon: Icon(Icons.delete, color: inquiryDetails!['problem_state'] == 1 ? Colors.grey : Colors.red),
                            ),
                            IconButton(
                              onPressed: inquiryDetails!['problem_state'] == 1 ? null : _showEditDialog,
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

  Widget _buildSection(String label, dynamic value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not Available',
              style: highlight
                  ? TextStyle(
                      color: value == 'In Transit' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
