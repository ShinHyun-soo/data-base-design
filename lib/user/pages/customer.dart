import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';
import 'package:sample_001/authentication/login.dart';
import 'package:sample_001/user/pages/customer/detail_order_page.dart';
import 'package:sample_001/user/pages/customer/order_page.dart';
import 'package:sample_001/user/pages/customer/create_inquiry_page.dart';
import 'package:sample_001/user/pages/customer/change_order_page.dart';
import 'package:sample_001/user/pages/customer/remote_order_page.dart';  
import 'package:shared_preferences/shared_preferences.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrintUserId();
    fetchOrders();
  }

  Future<void> debugPrintUserId() async {
    final userId = await getUserId();
    debugPrint('Logged-in user_id: $userId');
    if (userId == null) {
      _showSnackBar('No user_id found. Please log in again.', isError: true);
    }
  }

  Future<void> fetchOrders() async {
    try {
      final userId = await getUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.post(
        Uri.parse(API.getOrders),
        body: {'user_id': userId.toString()},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            orders = jsonResponse['data']
                .where((order) => order['current_state'] == 0) // Only orders with current_state = 0
                .toList();
            isLoading = false;
          });
        } else {
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to fetch orders', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error fetching orders: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse(API.deleteOrder),
        body: {'order_id': orderId},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          _showSnackBar('Order deleted successfully');
          fetchOrders();
        } else {
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to delete order', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error deleting order: $e', isError: true);
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
        title: const Text('고객 페이지'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('user_id');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
        ),
      ),
      endDrawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderCard(order);
                  },
                ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
              ),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.refresh,
            text: '새로고침',
            onTap: () {
              Navigator.pop(context);
              fetchOrders();
            },
          ),
          _buildDrawerItem(
            icon: Icons.shopping_cart,
            text: '주문 페이지',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderPage(onOrderSuccess: fetchOrders),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.message,
            text: '문의 페이지',
            onTap: () async {
              final userId = await getUserId();
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateInquiryPage(userId: userId),
                  ),
                );
              } else {
                _showSnackBar('User not logged in', isError: true);
              }
            },
          ),
          _buildDrawerItem(
            icon: Icons.list_alt,
            text: '주문 관리', // 주문 관리 메뉴 항목 추가
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RemoteOrderPage(), // 주문 관리 페이지로 이동
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      onTap: onTap,
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangeOrderPage(orderData: order),
                      ),
                    );
                    if (updated == true) fetchOrders();
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Order'),
                        content:
                            const Text('Are you sure you want to delete this order?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              deleteOrder(order['order_id'].toString());
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
