import 'package:deblur_frontend/UI/Login%20and%20SignUp/loginPage.dart';
import 'package:deblur_frontend/UI/Login%20and%20SignUp/otpVerifyPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
