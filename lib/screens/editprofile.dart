import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:mesme/screens/upload.dart';

class MeEditprofile extends StatefulWidget {
  const MeEditprofile({Key? key}) : super(key: key);

  @override
  State<MeEditprofile> createState() => _MeEditprofileState();
}

class _MeEditprofileState extends State<MeEditprofile> {
  bool isPasswordVisible = false;
  bool isLoading = true;
  TextEditingController _nameoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phonenoController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  UserModel? userData;
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> updateProfiledata() async {
    if (_phonenoController.text.length == 10) {
      String url = 'https://mesme.in/admin/api/users/update.php';
      var res = await http.post(Uri.parse(url), body: {
        "id": userData!.id,
        "name": _nameoController.text,
        "email": userData!.email,
        "phoneNumber": _phonenoController.text,
        "profilePhoto": userData!.profilePhoto,
        "password": userData!.password,
        "address": _addressController.text,
      });
      var response = jsonDecode(res.body);
      if (response['success'] == 'true') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Profile Updated successfully",
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
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Something went wrong",
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please enter valid phone number",
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

  Future<void> fetchLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Location permission denied'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = '';
      Placemark placemark = placemarks.first;
      address += placemark.street ?? '';
      address += ', ' + (placemark.subLocality ?? '');
      address += ', ' + (placemark.locality ?? '');
      address += ', ' + (placemark.administrativeArea ?? '');
      address += ', ' + (placemark.country ?? '');
      address += ', ' + (placemark.postalCode ?? '');

      setState(() {
        _addressController.text = address;
      });
    } catch (e) {
      print('Error fetching location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error fetching location. Please try again.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData().then((value) {
      setState(() {
        userData = UserModel.fromMap(value);
        _nameoController = TextEditingController(text: userData?.name ?? '');
        _phonenoController =
            TextEditingController(text: userData?.phoneNumber ?? '');
        _addressController =
            TextEditingController(text: userData?.address ?? '-');
        isLoading = false;
      });
    });
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      }
      var url = 'https://mesme.in/admin/api/users/get.php?id=${user.uid}';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
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
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.black,
              backgroundColor: Colors.white, // Loading spinner color
            ))
          : Container(
              padding: const EdgeInsets.all(18),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.8, color: Colors.black),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1)),
                                ],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    'https://mesme.in/admin/api/usersuploads/${userData?.profilePhoto ?? ''}',
                                  ),
                                )),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 0.8, color: Colors.black),
                                  color: Colors.black,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // Open image picker and navigate to MePhoto page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MePhoto(userId: userData?.id ?? ''),
                                      ),
                                    ).then((value) {
                                      getUserData().then((value) {
                                        setState(() {
                                          userData = UserModel.fromMap(value);
                                        });
                                      });
                                    });
                                  },
                                )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    BuildField(
                      'Name',
                      userData?.name ?? '',
                      false,
                      true,
                      _nameoController,
                    ),
                    BuildField(
                      'Email',
                      userData?.email ?? '',
                      false,
                      false,
                      _emailController,
                    ),
                    BuildField(
                      'Phone',
                      '',
                      false,
                      true,
                      _phonenoController,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: BuildField(
                            'Address',
                            '',
                            false,
                            true,
                            _addressController,
                          ),
                        ),
                        IconButton(
                          color: Colors.black,
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.black),
                          ),
                          icon: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                          ),
                          onPressed: fetchLocation,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await updateProfiledata();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'SAVE',
                            style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget BuildField(
    String labelText,
    String placeHolder,
    bool isPasswordTextField,
    bool isDisable,
    TextEditingController? controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: TextField(
        cursorColor: Colors.black87,
        controller: controller,
        style: const TextStyle(color: Colors.black),
        enabled: isDisable,
        obscureText: isPasswordTextField ? true : false,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 5),
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.black87),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeHolder,
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
