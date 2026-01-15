import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget{
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left:20,right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // VERY IMPORTANT
          
          children: [
            Text(
              "Sign Up",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: "Email"),),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: "password"),obscureText: true,),
            SizedBox(height:20),
            ElevatedButton(child:Text("Sign Up"), onPressed:() {print("Button is pressed");},),
          ],
        ),
        ),
      ),
    );
  }
}