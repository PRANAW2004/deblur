import 'package:deblur_frontend/Login%20and%20SignUp/otpVerifyPage.dart';
import 'package:deblur_frontend/toastMessage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupPage extends StatefulWidget{
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage>{

  final dio = Dio();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> sendToBackend() async{
    try{
      final baseUrl = dotenv.env['SERVER_URL'];
      Response response;
      response = await dio.post("${baseUrl}/signup",data: {"email": emailController.text.trim(), "password":passwordController.text.trim()});
      print(response.data.toString() == "success");
      if (response.data.toString() == "success"){
        Navigator.push(context, MaterialPageRoute(builder: (context) => OtpverifyPage(email: emailController.text.trim(),)));
      }else{
        showSnackBar(context, response.data["error"].toString(),color: Colors.red);
      }
    }catch(err){
      print(err);
    }
  }

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
            TextField(decoration: InputDecoration(labelText: "Email"),controller: emailController,),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: "password"),controller: passwordController,obscureText: true,),
            SizedBox(height:20),
            ElevatedButton(child:Text("Sign Up"), onPressed:() async {await sendToBackend();},),
          ],
        ),
        ),
      ),
    );
  }
}