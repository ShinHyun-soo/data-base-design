import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';
import 'package:sample_001/user/pages/employee/edit_report_details_page.dart';

class EditReportPage extends StatefulWidget {
  final int employeeId;

  const EditReportPage({Key? key, required this.employeeId}) : super(key: key);

  @override
  _EditReportPageState createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  List<dynamic> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      final response = await http.post(
        Uri.parse(API.getReportsByEmployee),
        body: {'employee_id': widget.employeeId.toString()},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            reports = jsonResponse['data'];
            isLoading = false;
          });
        } else {
          _showSnackBar('Failed to fetch reports', isError: true);
        }
      } else {
        _showSnackBar('Server error while fetching reports', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error fetching reports: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteReport(int reportId, int inquiryId) async {
    try {
      final response = await http.post(
        Uri.parse(API.deleteReport),
        body: {
          'report_id': reportId.toString(),
          'inquiry_id': inquiryId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          _showSnackBar('Report deleted successfully');
          fetchReports();
        } else {
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to delete report', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error deleting report: $e', isError: true);
    }
  }

  void navigateToEditReport(int reportId, String reportComment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReportDetailsPage(
          reportId: reportId,
          reportComment: reportComment,
        ),
      ),
    ).then((result) {
      if (result == true) {
        fetchReports();
      }
    });
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
        title: const Text('Edit Reports'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? const Center(child: Text('No reports found'))
              : ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final reportId = int.tryParse(report['report_id'].toString());
                    final inquiryId = int.tryParse(report['inquiry_id'].toString());
                    final reportComment = report['report_comment'] ?? 'No Comment';
                    final issueName = report['issue_name'] ?? 'Unknown Issue';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          'Inquiry ID: ${inquiryId ?? 'Unknown'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Issue: $issueName'),
                            Text(
                              'Comment: $reportComment',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                if (reportId != null) {
                                  navigateToEditReport(reportId, reportComment);
                                } else {
                                  _showSnackBar('Invalid report ID', isError: true);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (reportId != null && inquiryId != null) {
                                  deleteReport(reportId, inquiryId);
                                } else {
                                  _showSnackBar('Invalid report or inquiry ID', isError: true);
                                }
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
