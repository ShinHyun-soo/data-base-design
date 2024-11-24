import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';
import 'package:sample_001/authentication/login.dart';
import 'package:sample_001/user/pages/customer/detail_order_page.dart';
import 'package:sample_001/user/pages/customer/order_page.dart';
import 'package:sample_001/user/pages/customer/create_inquiry_page.dart';
import 'package:sample_001/user/pages/customer/change_order_page.dart';
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
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      debugPrint('Fetching orders...');
      final response = await http.get(Uri.parse(API.getOrders));
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        debugPrint('Parsed JSON: $jsonResponse');

        if (jsonResponse['success']) {
          setState(() {
            orders = jsonResponse['data'];
            isLoading = false;
          });
          debugPrint('Orders fetched: $orders');
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
          const SnackBar(content: Text('Failed to fetch orders')),
        );
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse(API.deleteOrder),
        body: {'order_id': orderId},
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            orders.removeWhere((order) => order['order_id'].toString() == orderId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order canceled successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel order')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> updateCurrentState() async {
    try {
      final response = await http.get(Uri.parse(API.updateCurrentState));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      }
      fetchOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating state: $e')),
      );
    }
  }

  Future<int?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  
  // 먼저 확인
  final userIdString = prefs.getString('user_id');
  
  // String을 int로 변환
  if (userIdString != null) {
    try {
      return int.parse(userIdString); // int로 변환
    } catch (e) {
      debugPrint('Error parsing user_id to int: $e');
      return null; // 변환 실패 시 null 반환
    }
  }

  return prefs.getInt('user_id'); // 기존에 int로 저장된 값도 확인
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Screen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('새로고침'),
              onTap: () {
                Navigator.pop(context);
                updateCurrentState();
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('문의 페이지'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not logged in')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('주문 페이지'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderPage(
                      onOrderSuccess: () => fetchOrders(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Receiver Name: ${order['receiver_name']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone: ${order['receiver_phone']}'),
                            Text('Address: ${order['receiver_address']}'),
                            Text('Zip Code: ${order['receiver_zip_code'] ?? "Not Available"}'),
                            Text('Product: ${order['product_name']}'),
                            Text('Order Date: ${order['order_date']}'),
                            Text('Delivery Date: ${order['availability_date']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search, color: Colors.green),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailOrderPage(orderId: int.parse(order['order_id'])),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChangeOrderPage(orderData: order),
                                  ),
                                );
                                if (updated == true) {
                                  fetchOrders();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Cancel Order'),
                                    content: const Text(
                                        'Are you sure you want to cancel this order?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          cancelOrder(order['order_id']);
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
