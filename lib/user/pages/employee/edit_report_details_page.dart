import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';

class EditReportDetailsPage extends StatefulWidget {
  final int reportId;
  final String reportComment;

  const EditReportDetailsPage({
    Key? key,
    required this.reportId,
    required this.reportComment,
  }) : super(key: key);

  @override
  _EditReportDetailsPageState createState() => _EditReportDetailsPageState();
}

class _EditReportDetailsPageState extends State<EditReportDetailsPage> {
  late TextEditingController _commentController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.reportComment);
  }

  Future<void> updateReportComment() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(API.updateReportComment),
        body: {
          'report_id': widget.reportId.toString(),
          'report_comment': _commentController.text,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          _showSnackBar('Report updated successfully', isError: false);
          Navigator.pop(context, true); // 성공 시 이전 화면으로 true 전달
        } else {
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to update the report. Please try again.', isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
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
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 편집'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Report Comment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : updateReportComment,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save Changes'),
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
    );
  }
}
