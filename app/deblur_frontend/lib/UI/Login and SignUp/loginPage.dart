import 'package:deblur_frontend/UI/Login%20and%20SignUp/signupPage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:  Center(
        child: Padding(
          padding: EdgeInsets.only(left:20,right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // VERY IMPORTANT
          
          children: [
            Text(
              "Login",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: "Email"),),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: "password"),obscureText: true,),
            SizedBox(height:20),
            ElevatedButton(child:Text("Login"), onPressed:() {print("Button is pressed");},),
            SizedBox(height:20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text("Don't have an account?"),
              GestureDetector(child: Text("Sign Up"),onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
                },)
            ],)
          ],
        ),
        ),
      ),
    );
  }
}