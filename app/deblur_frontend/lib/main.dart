import 'package:deblur_frontend/Login%20and%20SignUp/loginPage.dart';
import 'package:deblur_frontend/Login%20and%20SignUp/otpVerifyPage.dart';
import 'package:deblur_frontend/homePage.dart';
import 'package:deblur_frontend/secure_storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> main() async {
  await dotenv.load(fileName: ".env");
  final refreshToken = await AuthStorage.getRefreshToken();
  runApp(MyApp( isLoggedIn: refreshToken != null,));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn?HomePage():LoginPage(),
    );
  }
}
