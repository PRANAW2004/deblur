import 'package:deblur_frontend/Login%20and%20SignUp/forgotPasswordReset.dart';
import 'package:deblur_frontend/Login%20and%20SignUp/signupPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {
  final dio = Dio();

  TextEditingController emailController = TextEditingController();

  Future<void> sendOtp() async {
    try {
      final baseUrl = dotenv.env['SERVER_URL'];
      Response response;
      response = await dio.post(
        "${baseUrl}/forgot-password",
        data: {
          "email": emailController.text.trim(),
        },
      );
      print(response.data.toString());
      if (response.data.toString() == "success") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordReset(email: emailController.text.trim(),)));
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
              Text("Forgot Password", style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "Email"),
                controller: emailController,
              ),             
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Send Otp"),
                onPressed: () {
                  sendOtp();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
