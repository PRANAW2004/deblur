import 'package:deblur_frontend/Login%20and%20SignUp/loginPage.dart';
import 'package:deblur_frontend/toastMessage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OtpverifyPage extends StatefulWidget {
  final String email;
  const OtpverifyPage({super.key, required this.email});

  @override
  State<OtpverifyPage> createState() => _OtpverifyPage();
}

class _OtpverifyPage extends State<OtpverifyPage> {

  final dio = Dio();

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  Future<void> OtpVerify() async{
    try{
      var otp = "";
      for(var i=0;i<controllers.length;i++){
        otp += controllers[i].text;
      }
      print(otp);
      final baseUrl = dotenv.env['SERVER_URL'];
      Response response;
      response = await dio.post("${baseUrl}/otpverify",data: {"email": widget.email, "otp":otp});
      print(response.data.toString());
      if (response.data.toString() == "success"){
        showSnackBar(context, "Sign Up Successful", color: Colors.green);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()),(route) => false);
      }else{
        showSnackBar(context, response.data["error"].toString(),color: Colors.red);
      }
    }catch(err){
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
            mainAxisSize: MainAxisSize.min, // VERY IMPORTANT

            children: [
              Text("Verify Otp", style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
            
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _otpBox(index)),
              ),
              SizedBox(height:20),
               ElevatedButton(child:Text("Submit"), onPressed:() async {
                await OtpVerify();
                // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
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
    child: KeyboardListener(
      focusNode: FocusNode(), // separate focus for keyboard
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {

          if (controllers[index].text.isEmpty && index > 0) {
            controllers[index - 1].clear(); // 🔥 clear previous
            FocusScope.of(context)
                .requestFocus(focusNodes[index - 1]);
          }
        }
      },
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        autofocus: index == 0,
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context)
                .requestFocus(focusNodes[index + 1]);
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
    ),
  );
}





}

