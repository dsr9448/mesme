// // ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:mesme/models/usermodel.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/services/firebase_authservices.dart';
import 'package:provider/provider.dart';

class MeSignup extends StatefulWidget {
  const MeSignup({Key? key}) : super(key: key);

  @override
  State<MeSignup> createState() => _MeSignupState();
}

class _MeSignupState extends State<MeSignup> {
  // final FirebaseAuthServices _auth = FirebaseAuthServices();
  // bool isAuthInProgress = false;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phonenoController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add a GlobalKey for the form
  UserModel? userData;
  bool _passwordVisible = false; // Add this line to toggle password visibility

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phonenoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Consumer<FoodProvider>(
          builder: (context, foodProvider, child) {
            return foodProvider.isAuthInProgress
                ? const CircularProgressIndicator(color: Colors.orange)
                : ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                children: [
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Create Your Account ',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 24),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              autofocus: true,
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                fillColor: Colors.black,
                                focusColor: Colors.black,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.black87,
                                ),
                                labelText: 'Name',
                                labelStyle: TextStyle(color: Colors.black87),
                              ),
                              cursorColor: Colors.orange.shade700,
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              autofocus: false,
                              controller: _emailController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                fillColor: Colors.black,
                                focusColor: Colors.black,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.black87,
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.black87),
                              ),
                              cursorColor: Colors.orange.shade700,
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              autofocus: false,
                              controller: _phonenoController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                fillColor: Colors.orange,
                                focusColor: Colors.black,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                prefixIcon: Icon(
                                  Icons.call,
                                  color: Colors.black87,
                                ),
                                labelText: 'Phone Number',
                                labelStyle: TextStyle(color: Colors.black87),
                              ),
                              cursorColor: Colors.orange.shade700,
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 10) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _passwordController,
                              autofocus: false,
                              obscureText:
                                  !_passwordVisible, // Use _passwordVisible to toggle password visibility
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                fillColor: Colors.black,
                                focusColor: Colors.black,
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.black87,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.black87,
                                  ),
                                ),
                                labelText: 'Password',
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              cursorColor: Colors.orange.shade700,
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:  () async {
                                     signUp(foodProvider);
                                  },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade700,
                                ),
                                child: const Text(
                                  'Sign in',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
          }
      ),
    )
    );
  }
  Future<void> signUp(FoodProvider provider) async {
       String name = _usernameController.text;
    String email = _emailController.text;
    String phoneNumber = _phonenoController.text;
    String password = _passwordController.text;

    User? user = await provider.signUpWithEmailAndPassword(
        name, email, phoneNumber, password);

    if (user != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/location', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Welcome '),
        showCloseIcon: true,
        backgroundColor: Colors.orange.shade700,
        closeIconColor: Colors.white,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade800,
        content: const Text('Something went wrong. Please try again'),
        showCloseIcon: true,
        closeIconColor: Colors.white,
      ));
    }
  }
}

  // void signUp() async {
  //   String name = _usernameController.text;
  //   String email = _emailController.text;
  //   String phoneNumber = _phonenoController.text;
  //   String password = _passwordController.text;
  //   if (name != "" ||
  //       email != "" ||
  //       (phoneNumber != "" || phoneNumber.length != 10) ||
  //       password != "") {
  //     try {
    
  //       setState(() {
  //         isAuthInProgress = true;
  //       });

  //       User? user = await _auth.signupWithEmailandPassword(email, password);

  //       if (user != null) {
  //         var res = await http.post(
  //           Uri.parse('https://mesme.in/admin/api/users/create.php'),
  //           body: {
  //             "id": user.uid,
  //             "name": name,
  //             "email": email,
  //             "phoneNumber": phoneNumber,
  //             "profilePhoto": '',
  //             "password": password,
  //             "address": '',
  //           },
  //         );
  //         Navigator.pushNamedAndRemoveUntil(
  //           context,
  //           '/location',
  //           arguments: true,
  //           (route) => false,
  //         );
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Welcome $name'),
  //             backgroundColor: Colors.orange.shade700,
  //             showCloseIcon: true,
  //             closeIconColor: Colors.white,
  //           ),
  //         );
  //       } else {
  //         Navigator.pushNamed(context, '/welcome');
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             backgroundColor: Colors.red.shade700,
  //             content: const Text('invalid Credentials'),
  //             showCloseIcon: true,
  //             closeIconColor: Colors.white,
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       Navigator.pushNamed(context, '/welcome');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           backgroundColor: Colors.red,
  //           content: Text('Something went wrong'),
  //           showCloseIcon: true,
  //           closeIconColor: Colors.white,
  //         ),
  //       );
  //     } finally {
  //       setState(() {
  //         isAuthInProgress = false;
  //       });
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: Colors.red.shade700,
  //         content: const Text('please enter the data '),
  //         showCloseIcon: true,
  //         closeIconColor: Colors.white,
  //       ),
  //     );
  //   }
  // }
  

// }
