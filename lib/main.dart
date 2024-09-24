import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/screens/foodcart.dart';
import 'package:mesme/screens/forgetpassword.dart';
import 'package:mesme/screens/intro.dart';
import 'package:mesme/screens/location.dart';
import 'package:mesme/screens/profile.dart';
import 'package:mesme/screens/search.dart';
import 'package:mesme/screens/signup.dart';
import 'package:mesme/screens/welcome.dart';
import 'package:mesme/services/firebase_options.dart';
import 'package:mesme/widgets/navbar.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => FoodProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
        title: 'Mesme',
        theme: ThemeData(
            focusColor: Colors.white,
            fontFamily: GoogleFonts.poppins().fontFamily,
            primaryColor: Colors.white),
        color: Colors.white,
        initialRoute: '/introPage',
        routes: {
          '/introPage': (context) => const MeIntro(),
          '/home': (context) => const FoodBottomNavBar(),
          '/FoodCart': (context) => const FoodCart(),
          '/FoodProfile': (context) => const FoodProfile(),
          '/welcome': (context) => const MeWelcome(),
          '/location': (context) =>
              MeLocation(uid: FirebaseAuth.instance.currentUser!.uid),
          '/MeForgot': (context) => const MeForgot(),
          '/MeSignup': (context) =>   MeSignup(),
          '/MeSearch': (context) => SearchPage(),
        });
  }
}
