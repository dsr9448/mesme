import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MePhoto extends StatefulWidget {
  final String userId;

  const MePhoto({Key? key, required this.userId}) : super(key: key);

  @override
  _MePhotoState createState() => _MePhotoState();
}

class _MePhotoState extends State<MePhoto> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      try {
        // Convert image to bytes
        List<int> imageBytes = await _imageFile!.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        // Send image to server via HTTP POST request
        final response = await http.post(
          Uri.parse('https://mesme.in/admin/api/users/upload.php'),
          body: {
            'image': base64Image,
            'userId': widget.userId,
          },
        );

        // Handle response from server
        if (response.statusCode == 200) {
          // Photo uploaded successfully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Successfully updated profile picture",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.black,
              showCloseIcon: true,
              closeIconColor: Colors.white,
            ),
          );
          Navigator.of(context)
              .pop(); // You can handle success accordingly, e.g., navigate to another page
        } else {
          // Error uploading photo
          print('Error uploading photo: ${response.body}');
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Error uploading photo",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.red,
            showCloseIcon: true,
            closeIconColor: Colors.black,
          ));
        }
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Error uploading photo",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.red,
          showCloseIcon: true,
          closeIconColor: Colors.black,
        ));
        Navigator.of(context).pop();
      }
    } else {
      // No image selected, show error message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "No image selected",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.red,
        showCloseIcon: true,
        closeIconColor: Colors.black,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.black)),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Upload Profile Picture',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    width: 300,
                    fit: BoxFit.cover,
                    height: 300,
                  )
                : const Text('No image selected',
                    style: TextStyle(color: Colors.black)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 180,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Select Image',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _uploadImage,
              child: Container(
                width: 180,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Upload Image',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
