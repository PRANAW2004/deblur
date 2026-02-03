import 'dart:io';
import 'dart:typed_data';

import 'package:deblur_frontend/Login%20and%20SignUp/loginPage.dart';
import 'package:deblur_frontend/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _deblurredImageBytes;

  final dio = Dio();

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) return;

    final baseUrl = dotenv.env['SERVER_URL'];

    Dio dio = Dio();

    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        _image!.path,
        filename: _image!.path.split('/').last,
      ),
    });

    try {
      Response response = await dio.post(
        "$baseUrl/deblur",
        data: formData,
        options: Options(
          headers: {"Content-Type": "multipart/form-data"},
          responseType: ResponseType.bytes,
        ),
      );

      print("Response: ${response.data}");
      Uint8List imageBytes = Uint8List.fromList(response.data);

      // Save or display
      setState(() {
        _deblurredImageBytes = imageBytes;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Image")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Text("No image selected"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: uploadImage,
              child: const Text("Upload Image"),
            ),
            if (_deblurredImageBytes != null)
            Padding(padding: EdgeInsets.all(20),child: Image.memory(_deblurredImageBytes!),)
              
          ],
        ),
      ),
    );
  }
}
