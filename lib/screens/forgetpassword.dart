import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mesme/services/firebase_authservices.dart';

class MeForgot extends StatefulWidget {
  const MeForgot({Key? key}) : super(key: key);

  @override
  State<MeForgot> createState() => _MeForgotState();
}

class _MeForgotState extends State<MeForgot> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final FirebaseAuth _auths = FirebaseAuth.instance;
  bool isAuthInProgress = false;
  TextEditingController forgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (_auths.currentUser != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    forgetController.dispose();
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
                            'Trouble logging in? ',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: 24),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                              textAlign: TextAlign.center,
                              "Enter your email and we'll send you a link to get back into your account.",
                              style: TextStyle(color: Colors.black87)),
                          const SizedBox(height: 18),
                          TextFormField(
                            autofocus: false,
                            controller: forgetController,
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
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                var forgotpassword =
                                    forgetController.text.trim();
                                try {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                          email: forgotpassword)
                                      .then((value) => {
                                            Navigator.pushNamed(
                                                context, '/welcome'),
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Password reset link sent successfully'),
                                              showCloseIcon: true,
                                              closeIconColor: Colors.white,
                                              backgroundColor: Colors.black,
                                            ))
                                          });
                                } on FirebaseAuth catch (e) {
                                  Navigator.pushNamed(context, '/welcome');
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Something went wrong!"),
                                    backgroundColor: Colors.red,
                                    showCloseIcon: true,
                                    closeIconColor: Colors.black,
                                  ));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 0, 1),
                              ),
                              child: const Text(
                                'Send login link ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Or ',
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/MeSignup');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 0, 1),
                              ),
                              child: const Text(
                                'Create new account ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
