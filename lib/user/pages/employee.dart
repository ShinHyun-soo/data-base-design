import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample_001/user/pages/employee/create_report_page.dart';
import 'package:sample_001/user/pages/employee/edit_report_page.dart';
import 'package:sample_001/authentication/login.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({Key? key}) : super(key: key);

  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  List<dynamic> inquiries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInquiries();
  }

  Future<void> fetchInquiries() async {
    try {
      final response = await http.get(Uri.parse(API.getInquiries));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            inquiries = jsonResponse['data'];
            isLoading = false;
          });
        } else {
          _showSnackBar('Failed to fetch inquiries', isError: true);
        }
      } else {
        _showSnackBar('Server error while fetching inquiries', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error fetching inquiries: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<int?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('user_id');

    if (userIdString != null) {
      try {
        final userId = int.parse(userIdString);
        final response = await http.post(
          Uri.parse(API.getEmployeeId),
          body: {'user_id': userId.toString()},
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['success']) {
            return jsonResponse['data']['employee_id'];
          }
        }
      } catch (e) {
        debugPrint('Error fetching employee ID: $e');
      }
    }
    return null;
  }

  void navigateToEditReports() async {
    final employeeId = await getEmployeeId();
    if (employeeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditReportPage(employeeId: employeeId),
        ),
      ).then((_) => fetchInquiries());
    } else {
      _showSnackBar('Employee ID not found. Please log in again.', isError: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('직원 페이지'),
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
          : inquiries.isEmpty
              ? const Center(child: Text('No inquiries found'))
              : ListView.builder(
                  itemCount: inquiries.length,
                  itemBuilder: (context, index) {
                    final inquiry = inquiries[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          '${inquiry['user_name'] ?? 'Unknown User'} - '
                          '${inquiry['receiver_name'] ?? 'Unknown Receiver'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Comment: ${inquiry['inquiry_comment'] ?? 'No Comment'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.edit, color: Colors.blue),
                        onTap: () async {
                          final employeeId = await getEmployeeId();
                          if (employeeId != null) {
                            final inquiryId = int.tryParse(inquiry['inquiry_id'].toString());
                            if (inquiryId != null) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateReportPage(
                                    userName: inquiry['user_name'] ?? 'Unknown User',
                                    receiverName: inquiry['receiver_name'] ?? 'Unknown Receiver',
                                    productName: inquiry['product_name'] ?? 'Unknown Product',
                                    inquiryComment: inquiry['inquiry_comment'] ?? 'No Comment',
                                    employeeId: employeeId,
                                    inquiryId: inquiryId,
                                  ),
                                ),
                              );
                              if (result == true) fetchInquiries();
                            }
                          } else {
                            _showSnackBar('Employee ID not found. Please log in again.', isError: true);
                          }
                        },
                      ),
                    );
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
            text: '새로 고침',
            onTap: () {
              Navigator.pop(context);
              fetchInquiries();
            },
          ),
          _buildDrawerItem(
            icon: Icons.list_alt,
            text: '문의 관리',
            onTap: navigateToEditReports,
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
}
