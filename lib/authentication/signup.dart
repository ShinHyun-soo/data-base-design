import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample_001/api/api.dart';
import 'package:sample_001/model/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  var formKey = GlobalKey<FormState>();

  var userNameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneController = TextEditingController();
  var addressController = TextEditingController();

  String userType = 'customer'; // 기본값을 'customer'로 설정

  // 전화번호 포맷 함수
  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 11) {
      return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7)}';
    }
    return phoneNumber;
  }

  checkUserEmail() async {
    try {
      var response = await http.post(Uri.parse(API.validateEmail),
          body: {'user_email': emailController.text.trim()});

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        if (responseBody['exitEmail'] == true) {
          Fluttertoast.showToast(
            msg: "Email is already in use. Please try another email",
          );
        } else {
          saveInfo();
        }
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  saveInfo() async {
  String formattedPhone = formatPhoneNumber(phoneController.text.trim());
  User userModel = User(
    1,
    userNameController.text.trim(),
    emailController.text.trim(),
    passwordController.text.trim(),
    formattedPhone,
    addressController.text.trim(),
    userType,
  );

  try {
    var res = await http.post(
      Uri.parse(API.signup),
      body: userModel.toJson(),
    );

    if (res.statusCode == 200) {
      var resSignup = jsonDecode(res.body);
      if (resSignup['success'] == true) {
        String userId = resSignup['user_id'].toString(); // 회원가입 완료 후 받은 user_id
        
        if (userType == 'employee') {
          await addEmployee(userId); // user_id를 addEmployee 함수에 전달
        }

        Fluttertoast.showToast(msg: 'Signup successfully');
        setState(() {
          userNameController.clear();
          emailController.clear();
          passwordController.clear();
          phoneController.clear();
          addressController.clear();
          userType = 'customer';
        });
      } else {
        Fluttertoast.showToast(msg: 'Error occurred. Please try again');
      }
    }
  } catch (e) {
    print(e.toString());
    Fluttertoast.showToast(msg: e.toString());
  }
}

// addEmployee 메서드
Future<void> addEmployee(String userId) async {
  try {
    var response = await http.post(
      Uri.parse(API.addEmployee),
      body: {'user_id': userId},
    );

    print("Employee API response: ${response.body}");
  } catch (e) {
    print("Error adding employee: $e");
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.card_travel_outlined,
                  color: Colors.deepPurple,
                  size: 100,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Sign Up',
                  style: GoogleFonts.bebasNeue(fontSize: 36.0),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Thank you for joining us',
                    style: GoogleFonts.bebasNeue(fontSize: 28)),
                SizedBox(
                  height: 50,
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: userNameController,
                              validator: (val) =>
                                  val == "" ? "Please enter username" : null,
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: 'User'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: emailController,
                              validator: (val) =>
                                  val == "" ? "Please enter email" : null,
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: 'Email'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: passwordController,
                              validator: (val) =>
                                  val == "" ? "Please enter password" : null,
                              obscureText: true,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Password'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                setState(() {
                                  phoneController.text =
                                      formatPhoneNumber(value);
                                  phoneController.selection =
                                      TextSelection.fromPosition(TextPosition(
                                          offset:
                                              phoneController.text.length));
                                });
                              },
                              validator: (val) => val == null || val.isEmpty || val.replaceAll('-', '').length != 11
                              ? "Please enter a valid phone number"
                              : null,
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: 'Phone'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: addressController,
                              validator: (val) =>
                                  val == "" ? "Please enter address" : null,
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: 'Address'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            value: 'employee',
                            groupValue: userType,
                            onChanged: (value) {
                              setState(() {
                                userType = value!;
                              });
                            },
                          ),
                          Text('Employee'),
                          Radio(
                            value: 'customer',
                            groupValue: userType,
                            onChanged: (value) {
                              setState(() {
                                userType = value!;
                              });
                            },
                          ),
                          Text('Customer'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      checkUserEmail();
                    }
                  },
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already registered?'),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        ' Go back to Login page!',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
