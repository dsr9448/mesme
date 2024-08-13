import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/services/firebase_authservices.dart';

class MeLogin extends StatefulWidget {
  const MeLogin({Key? key}) : super(key: key);

  @override
  State<MeLogin> createState() => _MeLoginState();
}

class _MeLoginState extends State<MeLogin> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final FirebaseAuth _auths = FirebaseAuth.instance;
  bool isAuthInProgress = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (_auths.currentUser != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        ).then((value) async {
          await FoodProvider().fetchSavedAddress();
          await FoodProvider().fetchOrders();
        });
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: isAuthInProgress
            ? const CircularProgressIndicator(
                color: Colors.black,
              )
            : ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                children: [
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Welcome Back ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Login to your existing account',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            autofocus: false,
                            controller: emailController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.black,
                              focusColor: Colors.black,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87),
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.black87,
                              ),
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.black87),
                            ),
                            cursorColor: Colors.black,
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            autofocus: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.black,
                              focusColor: Colors.black,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87),
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.black87,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText =
                                        !_obscureText; // Toggle password visibility
                                  });
                                },
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black87,
                                ),
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.black87),
                            ),
                            cursorColor: Colors.black,
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment:
                                Alignment.centerRight, // Align to the right
                            child: GestureDetector(
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(color: Colors.black),
                              ),
                              onTap: () {
                                // Navigator.push(context, MeForgot());
                                Navigator.pushNamed(context, '/MeForgot');
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 0, 0),
                              ),
                              child: const Text(
                                'Log In',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> signUp() async {
    setState(() {
      isAuthInProgress = true; // Set to true before login process starts
    });

    String email = emailController.text;
    String password = passwordController.text;
    User? user = await _auth.loginWithEmailandPassword(email, password);

    setState(() {
      isAuthInProgress =
          false; // Set back to false after login process completes
    });

    if (user != null) {
      print('login in');
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Welcome back'),
        showCloseIcon: true,
        backgroundColor: Colors.black,
        closeIconColor: Colors.white,
      ));
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, '/introPage', (route) => false);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('something went wrong'),
        showCloseIcon: true,
        closeIconColor: Colors.white,
      ));
    }
  }
}
