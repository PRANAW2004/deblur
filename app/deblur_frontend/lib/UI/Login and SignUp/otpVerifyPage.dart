import 'package:deblur_frontend/UI/Login%20and%20SignUp/loginPage.dart';
import 'package:flutter/material.dart';

class OtpverifyPage extends StatefulWidget {
  const OtpverifyPage({super.key});

  @override
  State<OtpverifyPage> createState() => _OtpverifyPage();
}

class _OtpverifyPage extends State<OtpverifyPage> {

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // VERY IMPORTANT

            children: [
              Text("Verify Otp", style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
            
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _otpBox(index)),
              ),
              SizedBox(height:20),
               ElevatedButton(child:Text("Submit"), onPressed:() {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
              },),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
  return SizedBox(
    width: 50,
    height: 55,
    child: TextField(
      controller: controllers[index],
      focusNode: focusNodes[index],
      autofocus: index == 0,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      onChanged: (value) {
        if (value.length == 1) {
          if (index < 5) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else {
            FocusScope.of(context).unfocus();
          }
        } else if (value.isEmpty && index > 0) {
          FocusScope.of(context).requestFocus(focusNodes[index - 1]);
        }
      },
      decoration: InputDecoration(
        counterText: "",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    ),
  );
}


}

