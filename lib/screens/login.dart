import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/services/firebase_authservices.dart';
import 'package:provider/provider.dart';
class MeLogin extends StatefulWidget {
  const MeLogin({Key? key}) : super(key: key);

  @override
  State<MeLogin> createState() => _MeLoginState();
}

class _MeLoginState extends State<MeLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Welcome Back',
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
                                controller: emailController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.orange),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.orange, width: 2.0),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Colors.black87,
                                  ),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.black87),
                                ),
                                cursorColor: Colors.orange,
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: passwordController,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.orange),
                                  ),
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
                                        _obscureText = !_obscureText;
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
                                  labelStyle:
                                      const TextStyle(color: Colors.black87),
                                ),
                                cursorColor: Colors.black,
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 18),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/MeForgot');
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await signIn(foodProvider);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text(
                                    'Log In',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Future<void> signIn(FoodProvider provider) async {
    String email = emailController.text;
    String password = passwordController.text;

    User? user = await provider.loginWithEmailAndPassword(email, password);

    if (user != null) {
      // User logged in successfully, navigate to home screen
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Welcome back'),
        showCloseIcon: true,
        backgroundColor: Colors.orange.shade700,
        closeIconColor: Colors.white,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade800,
        content: const Text('Login failed. Please try again.'),
        showCloseIcon: true,
        closeIconColor: Colors.white,
      ));
    }
  }
}



