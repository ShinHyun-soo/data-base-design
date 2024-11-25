import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';

class CreateInquiryPage extends StatefulWidget {
  final int userId;

  const CreateInquiryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CreateInquiryPageState createState() => _CreateInquiryPageState();
}

class _CreateInquiryPageState extends State<CreateInquiryPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedParcelId;
  final TextEditingController _inquiryController = TextEditingController();
  List<dynamic> parcels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableParcels();
  }

  Future<void> fetchAvailableParcels() async {
    try {
      final response = await http.post(
        Uri.parse(API.getAvailableParcels),
        body: {'user_id': widget.userId.toString()},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            parcels = jsonResponse['data'];
            isLoading = false;
          });
        } else {
          _showSnackBar(jsonResponse['message'], isError: true);
        }
      } else {
        _showSnackBar('Failed to fetch parcels', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error fetching parcels: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> submitInquiry() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse(API.submitInquiry),
          body: {
            'user_id': widget.userId.toString(),
            'parcel_id': selectedParcelId,
            'inquiry_comment': _inquiryController.text,
          },
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['success']) {
            _showSnackBar(jsonResponse['message']);
            Navigator.pop(context, true);
          } else {
            _showSnackBar(jsonResponse['message'], isError: true);
          }
        } else {
          _showSnackBar('Failed to submit inquiry', isError: true);
        }
      } catch (e) {
        _showSnackBar('Error submitting inquiry: $e', isError: true);
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
      appBar: AppBar(
        title: const Text('Create Inquiry'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedParcelId,
                      items: parcels.map<DropdownMenuItem<String>>((parcel) {
                        return DropdownMenuItem<String>(
                          value: parcel['parcel_id'].toString(),
                          child: Text(parcel['description'] ?? 'Unknown Parcel'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedParcelId = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Parcel',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null ? 'Please select a parcel' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _inquiryController,
                      decoration: const InputDecoration(
                        labelText: 'Inquiry Comment',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your inquiry comment';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: submitInquiry,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Inquiry'),
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
}
