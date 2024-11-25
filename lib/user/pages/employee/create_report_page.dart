import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';

class CreateReportPage extends StatefulWidget {
  final String userName;
  final String receiverName;
  final String productName;
  final String inquiryComment;
  final int employeeId;
  final int inquiryId;

  const CreateReportPage({
    Key? key,
    required this.userName,
    required this.receiverName,
    required this.productName,
    required this.inquiryComment,
    required this.employeeId,
    required this.inquiryId,
  }) : super(key: key);

  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> issues = [];
  int? selectedIssueId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    try {
      final response = await http.get(Uri.parse(API.getIssues));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            issues = jsonResponse['data'];
            isLoading = false;
          });
        }
      } else {
        setState(() => isLoading = false);
        _showSnackBar('Failed to load issues', isError: true);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error fetching issues: $e', isError: true);
    }
  }

  Future<void> submitReport() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse(API.submitReport),
          body: {
            'inquiry_id': widget.inquiryId.toString(),
            'issue_id': selectedIssueId.toString(),
            'report_comment': _commentController.text,
            'employee_id': widget.employeeId.toString(),
          },
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['success']) {
            _showSnackBar('Report submitted successfully');
            Navigator.pop(context, true);
          } else {
            _showSnackBar(jsonResponse['message'], isError: true);
          }
        } else {
          _showSnackBar('Failed to submit report', isError: true);
        }
      } catch (e) {
        _showSnackBar('Error submitting report: $e', isError: true);
      }
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
      appBar: AppBar(title: const Text('Create Report')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildInfoSection('User Name', widget.userName),
                    _buildInfoSection('Receiver Name', widget.receiverName),
                    _buildInfoSection('Product Name', widget.productName),
                    _buildInfoSection('Inquiry Comment', widget.inquiryComment),
                    const Divider(),
                    DropdownButtonFormField<int>(
                      value: selectedIssueId,
                      onChanged: (value) => setState(() => selectedIssueId = value),
                      items: issues.map((issue) {
                        return DropdownMenuItem<int>(
                          value: int.tryParse(issue['issue_id'].toString()),
                          child: Text(issue['issue_name']),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Select Issue',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null ? 'Please select an issue' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        labelText: 'Report Comment',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter a comment' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: submitReport,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Report'),
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

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
