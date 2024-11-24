import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/api/api.dart';

class CreateInquiryPage extends StatefulWidget {
  final int userId; // 사용자 ID

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
      debugPrint('Fetching available parcels for user ID: ${widget.userId}');
      final response = await http.post(
        Uri.parse(API.getAvailableParcels),
        body: {'user_id': widget.userId.toString()},
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        debugPrint('Parsed JSON: $jsonResponse');

        if (jsonResponse['success']) {
          setState(() {
            parcels = jsonResponse['data'];
            isLoading = false;
          });
          debugPrint('Available parcels: $parcels');
        } else {
          setState(() {
            isLoading = false;
          });
          debugPrint('Error message: ${jsonResponse['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint('Failed to fetch parcels: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch parcels')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Exception occurred while fetching parcels: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> submitInquiry() async {
    if (_formKey.currentState!.validate()) {
      if (selectedParcelId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a parcel')),
        );
        return;
      }

      try {
        debugPrint('Submitting inquiry for user ID: ${widget.userId}');
        debugPrint('Selected Parcel ID: $selectedParcelId');
        debugPrint('Inquiry Comment: ${_inquiryController.text}');

        final response = await http.post(
          Uri.parse(API.submitInquiry),
          body: {
            'user_id': widget.userId.toString(),
            'parcel_id': selectedParcelId,
            'inquiry_comment': _inquiryController.text,
          },
        );

        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          debugPrint('Parsed JSON: $jsonResponse');

          if (jsonResponse['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse['message'])),
            );
            Navigator.pop(context, true);
          } else {
            debugPrint('Error message: ${jsonResponse['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse['message'])),
            );
          }
        } else {
          debugPrint('Failed to submit inquiry: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit inquiry')),
          );
        }
      } catch (e) {
        debugPrint('Exception occurred while submitting inquiry: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
      child: Text('${parcel['description'] ?? 'Unknown'}'),
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
  validator: (value) =>
      value == null ? 'Please select a parcel' : null,
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
                    ElevatedButton(
                      onPressed: submitInquiry,
                      child: const Text('Submit Inquiry'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
