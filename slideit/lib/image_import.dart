import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Image> fetchAndSaveImageGallery() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  Image result = Image.network("https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg?20200913095930");

  if (pickedFile != null) {
    File originalFile = File(pickedFile.path);
    late Uint8List imageBytes;

    if (kIsWeb) {
      imageBytes = await pickedFile.readAsBytes();
    } else {
      imageBytes = await originalFile.readAsBytes();
    }

    img.Image? image = img.decodeImage(imageBytes);
    if (image != null) {
      int size = image.width < image.height ? image.width : image.height;
      img.Image croppedImage = img.copyCrop(image, x: 0, y: 0, width: size, height: size);
      Uint8List croppedBytes = Uint8List.fromList(img.encodePng(croppedImage));
      result = Image.memory(croppedBytes, fit: BoxFit.scaleDown,);
      String base64Image = base64Encode(croppedBytes);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('imageBase64', base64Image);
    }
  }

  return result;
}

Future<Image> fetchAndSaveImageRandom(String imageUrl) async {
  Image result = Image.network("https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg?20200913095930");
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode == 200) {
    Uint8List  bytes = response.bodyBytes;
    result = Image.memory(bytes, fit: BoxFit.scaleDown,);
    String base64Image = base64Encode(bytes);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('imageBase64', base64Image);
  }

  return result;
}