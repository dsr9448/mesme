import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/screens/welcome.dart';
import 'package:mesme/widgets/onboard.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MeIntro extends StatefulWidget {
  const MeIntro({super.key});

  @override
  State<MeIntro> createState() => _MeIntroState();
}

class _MeIntroState extends State<MeIntro> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isAuthInProgress = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_auth.currentUser != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Stack(
          children: [
            PageView(
              controller: controller.pageController,
              onPageChanged: controller.updatePageIndicator,
              children: const [
                onBoard(
                    image: 'images/1.jpeg',
                    title: 'Order your favorite food',
                    subtitle:
                        'Discover exclusive & delicious foods over 300+ restaurants.'),
                onBoard(
                    image: 'images/2.jpg',
                    title: 'Search for favorite Grocery',
                    subtitle:
                        'Find fresh and quality groceries from 300+ stores, easily.'),
                onBoard(
                    image: 'images/3.jpeg',
                    title: 'Fast delivery at your place',
                    subtitle:
                        'Fast delivery to your home, office or wherever you are.'),
              ],
            ),
             Positioned(
                top: kToolbarHeight,
                right: 18,
                child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.orange.shade700)),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const MeWelcome()));
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white),
                    ))),
            Positioned(
                bottom: kBottomNavigationBarHeight,
                left: 18,
                child: SmoothPageIndicator(
                  onDotClicked: controller.dotNavigatorClick,
                  controller: controller.pageController,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                      activeDotColor: Colors.orange, dotHeight: 6),
                )),
            Positioned(
                bottom: kBottomNavigationBarHeight,
                right: 18,
                child: ElevatedButton(
                    onPressed: () {
                      OnboardController.instance.nextPage(context);
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.orange.shade700),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                    )))
          ],
        ),
      ),
    );
  }
}

class onBoard extends StatelessWidget {
  const onBoard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image, title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 150,
          ),
          Text(title.trim(),
              style: GoogleFonts.montserratAlternates(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              )),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          Center(
            child: Image(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              image: AssetImage(image),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}
