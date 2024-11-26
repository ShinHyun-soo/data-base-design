import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample_001/user/pages/customer/detail_order_page.dart';

class RemoteOrderPage extends StatefulWidget {
  const RemoteOrderPage({Key? key}) : super(key: key);

  @override
  _RemoteOrderPageState createState() => _RemoteOrderPageState();
}

class _RemoteOrderPageState extends State<RemoteOrderPage> {
  List<dynamic> remoteOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRemoteOrders();
  }

  Future<void> fetchRemoteOrders() async {
    try {
      final userId = await getUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.post(
        Uri.parse(API.getRemoteOrders), // Remote orders API 호출
        body: {'user_id': userId.toString()},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            remoteOrders = jsonResponse['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to fetch remote orders', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error fetching remote orders: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('user_id');
    if (userIdString != null) return int.tryParse(userIdString);
    return prefs.getInt('user_id');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 관리'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : remoteOrders.isEmpty
              ? const Center(child: Text('No remote orders found'))
              : ListView.builder(
                  itemCount: remoteOrders.length,
                  itemBuilder: (context, index) {
                    final order = remoteOrders[index];
                    return _buildRemoteOrderCard(order);
                  },
                ),
    );
  }

  Widget _buildRemoteOrderCard(Map<String, dynamic> order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receiver: ${order['receiver_name']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Phone: ${order['receiver_phone']}'),
            Text('Address: ${order['receiver_address']}'),
            Text('Delivery Date: ${order['availability_date']}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailOrderPage(
                          orderId: order['order_id'],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
