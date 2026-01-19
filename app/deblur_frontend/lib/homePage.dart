import 'package:deblur_frontend/Login%20and%20SignUp/loginPage.dart';
import 'package:deblur_frontend/secure_storage/secure_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Text("This is HomePage"),
          ElevatedButton(
            onPressed: () async {
              await AuthStorage.clear();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            child: Text("Log out"),
          ),
        ],
      ),
    );
  }
}
