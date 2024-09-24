import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:http/http.dart' as http;
import 'package:mesme/screens/customersupport.dart';
import 'package:mesme/screens/editprofile.dart';
import 'package:mesme/screens/privacy.dart';

class FoodProfile extends StatefulWidget {
  const FoodProfile({super.key});

  @override
  State<FoodProfile> createState() => _FoodProfileState();
}

class _FoodProfileState extends State<FoodProfile> {
  UserModel? userData;
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserData();
  }

  Future<void> getUserData() async {
    setState(() {
      isLoading = true;
    });
    try {
      User? user = firebaseAuth.currentUser;

      if (user == null) {
        throw Exception('User is not authenticated');
      }
      var url = 'https://mesme.in/admin/api/users/get.php?id=${user.uid}';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          userData = UserModel.fromMap(jsonDecode(response.body));
          isLoading = false;
        });
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
              backgroundColor: WidgetStatePropertyAll(Colors.orange)),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.orange.shade700,
              backgroundColor: Colors.white, // Loading spinner color
            ))
          : Container(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          'https://mesme.in/admin/api/usersuploads/${userData?.profilePhoto ?? ''}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    userData?.name ?? '-',
                    style: GoogleFonts.poppins(
                      color: Colors.black, // Text color
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    userData?.email ?? '',
                    style: GoogleFonts.poppins(
                      color: Colors.black54, // Text color
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const MeEditprofile();
                          },
                        ),
                      ).then((_) {
                        getUserData();
                      });
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    leading: Icon(
                      Icons.settings,
                      color: Colors.orange.shade700, // Icon color
                    ),
                    title: Text(
                      'Account Settings',
                      style: GoogleFonts.poppins(
                        color: Colors.black, // Text color
                      ),
                    ),
                    titleAlignment: ListTileTitleAlignment.center,
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.orange.shade700, // Icon color
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const MeCustomer()));
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    leading: Icon(
                      Icons.support_agent_rounded,
                      color: Colors.orange.shade700, // Icon color
                    ),
                    title: Text(
                      'Customer Support',
                      style: GoogleFonts.poppins(
                        color: Colors.black, // Text color
                      ),
                    ),
                    titleAlignment: ListTileTitleAlignment.center,
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.orange.shade700, // Icon color
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MePolicy()));
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    leading: Icon(
                      Icons.privacy_tip,
                      color: Colors.orange.shade700, // Icon color
                    ),
                    title: Text(
                      'Privacy Policy',
                      style: GoogleFonts.poppins(
                        color: Colors.black, // Text color
                      ),
                    ),
                    titleAlignment: ListTileTitleAlignment.center,
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.orange.shade700, // Icon color
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      FirebaseAuth.instance.signOut().whenComplete(() {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/welcome', (route) => false);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Logout successful.'),
                        showCloseIcon: true,
                        backgroundColor: Colors.orange.shade700,
                        closeIconColor: Colors.white,
                      ));
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    leading: Icon(Icons.logout,
                        color: Colors.orange.shade700 // Icon color
                        ),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        color: Colors.black, // Text color
                      ),
                    ),
                    titleAlignment: ListTileTitleAlignment.center,
                  ),
                ],
              ),
            ),
    );
  }
}
