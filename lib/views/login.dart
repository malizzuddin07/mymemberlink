import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_member_link/myconfig.dart';
import 'package:my_member_link/views/main_screen.dart';
import 'package:my_member_link/views/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool rememberme = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/login.png',
                  height: 300,
                ),
                const SizedBox(height: 30),
                const Text("LOGIN",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                TextField(
                  controller: emailcontroller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(127, 0, 0, 0),
                    hintText: "Your Email",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordcontroller,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(127, 0, 0, 0),
                    hintText: "Your Password",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Text("Remember me"),
                    Checkbox(
                      value: rememberme,
                      onChanged: (bool? value) {
                        setState(() {
                          String email = emailcontroller.text;
                          String pass = passwordcontroller.text;
                          if (value!) {
                            if (email.isNotEmpty && pass.isNotEmpty) {
                              storeSharedPrefs(value, email, pass);
                            } else {
                              rememberme = false;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Please enter your credentials"),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }
                          } else {
                            email = "";
                            pass = "";
                            storeSharedPrefs(value, email, pass);
                          }
                          rememberme = value;
                          setState(() {});
                        });
                      },
                    ),
                  ],
                ),
                MaterialButton(
                    elevation: 10,
                    onPressed: onLogin,
                    minWidth: 400,
                    height: 50,
                    color: Colors.blue[800],
                    child: const Text("Login",
                        style: TextStyle(color: Colors.white))),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  child: const Text("Forgot Password?"),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (content) => const RegisterScreen()));
                  },
                  child: const Text("Create new account?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onLogin() async {
    String email = emailcontroller.text;
    String password = passwordcontroller.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter email and password"),
      ));
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/login_users.php"),
        body: {"email": email, "password": password},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login Success"),
            backgroundColor: Colors.green,
          ));
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (content) => const MainScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login Failed"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Server error: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> storeSharedPrefs(bool value, String email, String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setString("email", email);
      await prefs.setString("password", pass);
      await prefs.setBool("rememberme", value);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Stored"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));
    } else {
      await prefs.remove("email");
      await prefs.remove("password");
      await prefs.setBool("rememberme", value);
      emailcontroller.clear();
      passwordcontroller.clear();
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailcontroller.text = prefs.getString("email") ?? "";
    passwordcontroller.text = prefs.getString("password") ?? "";
    rememberme = prefs.getBool("rememberme") ?? false;
    setState(() {});
  }
}
