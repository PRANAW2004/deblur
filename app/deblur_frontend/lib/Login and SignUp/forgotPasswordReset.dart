import 'package:deblur_frontend/Login%20and%20SignUp/forgotPasswordverify.dart';
import 'package:deblur_frontend/Login%20and%20SignUp/loginPage.dart';
import 'package:deblur_frontend/Login%20and%20SignUp/signupPage.dart';
import 'package:deblur_frontend/toastMessage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ForgotPasswordReset extends StatefulWidget {
  final String email;
  const ForgotPasswordReset({super.key,required this.email});

  @override
  State<ForgotPasswordReset> createState() => _ForgotPasswordReset();
}

class _ForgotPasswordReset extends State<ForgotPasswordReset> {
  final dio = Dio();

  TextEditingController otpController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController retypepasswordController = TextEditingController();


  Future<void> login() async {
    try {
      if (passwordController.text.trim() != retypepasswordController.text.trim()){
        print("Passwords do not match");
      }
      else{
      final baseUrl = dotenv.env['SERVER_URL'];
      Response response;
      response = await dio.post(
        "${baseUrl}/confirm-forgot-password",
        data: {
          "email": widget.email,
          "otp": otpController.text.trim(),
          "newPassword":passwordController.text.trim()
        },
      );
      print(response.data.toString());
      if (response.data.toString() == "success") {
        showSnackBar(context, "Password Reset Succesfull", color: Colors.green);
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
      else{
        showSnackBar(context, response.data["error"].toString(),color:Colors.red);
      }
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
                decoration: InputDecoration(labelText: "otp"),
                controller: otpController,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "new password"),
                obscureText: true,
                controller: passwordController,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "retype new password"),
                obscureText: true,
                controller: retypepasswordController,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Reset Password"),
                onPressed: () {
                  login();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
