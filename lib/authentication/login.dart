import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample_001/api/api.dart';
import 'package:sample_001/authentication/signup.dart';
import 'package:http/http.dart' as http;
import 'package:sample_001/model/user.dart';
import 'package:sample_001/user/pages/customer.dart';
import 'package:sample_001/user/pages/employee.dart';
import 'package:sample_001/user/user_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Save user_id to SharedPreferences
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  // User login function
  Future<void> userLogin() async {
    if (!formKey.currentState!.validate()) return;

    try {
      var res = await http.post(
        Uri.parse(API.login),
        body: {
          'user_email': emailController.text.trim(),
          'user_password': passwordController.text.trim()
        },
      );

      if (res.statusCode == 200) {
        var resLogin = jsonDecode(res.body);
        if (resLogin['success'] == true) {
          Fluttertoast.showToast(msg: 'Login successfully');
          
          // Save user_id in SharedPreferences
          String userId = resLogin['userData']['user_id'].toString();
          await saveUserId(userId);
          
          // Save user information for session persistence
          User userInfo = User.fromJson(resLogin['userData']);
          await RememberUser.saveRememberUserInfo(userInfo);

          // Navigate based on user type
          if (userInfo.user_type == 'employee') {
            Get.off(() => EmployeePage());
          } else if (userInfo.user_type == 'customer') {
            Get.off(() => CustomerPage());
          }

          // Clear the input fields
          emailController.clear();
          passwordController.clear();
        } else {
          Fluttertoast.showToast(msg: 'Please check your email and password');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error');
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
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
                  Icons.phone_android,
                  size: 100,
                ),
                SizedBox(height: 30),
                Text(
                  'Hello',
                  style: GoogleFonts.bebasNeue(fontSize: 36.0),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 50),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: emailController,
                              validator: (val) => val!.isEmpty ? "Please enter email" : null,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email',
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: passwordController,
                              validator: (val) => val!.isEmpty ? "Please enter password" : null,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: userLogin,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not a member?'),
                    GestureDetector(
                      onTap: () => Get.to(() => SignupPage()),
                      child: Text(
                        ' Register Now!',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
