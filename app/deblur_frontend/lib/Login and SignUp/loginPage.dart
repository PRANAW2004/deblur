import 'package:deblur_frontend/Login%20and%20SignUp/forgotPasswordverify.dart';
import 'package:deblur_frontend/Login%20and%20SignUp/signupPage.dart';
import 'package:deblur_frontend/homePage.dart';
import 'package:deblur_frontend/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../toastMessage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final dio = Dio();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    try {
      final baseUrl = dotenv.env['SERVER_URL'];
      Response response;
      response = await dio.post(
        "${baseUrl}/login",
        data: {
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );
      print(response.data["error"].toString());
      if (response.data["message"].toString() == "success") {
        showSnackBar(context, "Login Successful",color: Colors.green);
        final refreshToken = response.data["refreshToken"];
        await AuthStorage.saveRefreshToken(refreshToken);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
      }else{
        showSnackBar(context, response.data["error"].toString(), color:Colors.red);
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Login", style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "Email"),
                controller: emailController,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "password"),
                obscureText: true,
                controller: passwordController,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Login"),
                onPressed: () {
                  login();
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  GestureDetector(
                    child: Text("Sign Up"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
