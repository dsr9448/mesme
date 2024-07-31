import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/screens/grocery.dart';
import 'package:mesme/screens/home.dart';
import 'package:mesme/screens/orders.dart';

class FoodBottomNavBar extends StatefulWidget {
  const FoodBottomNavBar({super.key});

  @override
  _FoodBottomNavBarState createState() => _FoodBottomNavBarState();
}

class _FoodBottomNavBarState extends State<FoodBottomNavBar> {
  int currentTab = 0;
  final List<Widget> screens = [
    const HomeScreen(),
  ];
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageStorage(bucket: bucket, child: currentScreen),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: Colors.black26,
            ),
          ),
          BottomAppBar(
            color: const Color.fromARGB(255, 255, 255, 255),
            shape: const CircularNotchedRectangle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 4.0), // Adjusted padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          currentScreen = const HomeScreen();
                          currentTab = 0;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.dinner_dining,
                            color: currentTab == 0
                                ? Colors.black
                                : Colors.black87,
                          ),
                          Text(
                            'Food',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12, // Adjusted font size
                                color: currentTab == 0
                                    ? Colors.black
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          currentScreen = const GroceryScreen();
                          currentTab = 1;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_grocery_store,
                            color: currentTab == 1
                                ? Colors.black
                                : Colors.black45,
                          ),
                          Text(
                            'Grocery',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12, // Adjusted font size
                                color: currentTab == 1
                                    ? Colors.black
                                    : Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          currentScreen =
                              OrderListPage(); // Change this to the appropriate screen for Orders
                          currentTab = 2;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.watch_later_outlined,
                            color: currentTab == 2
                                ? Colors.black
                                : Colors.black45,
                          ),
                          Text(
                            'Orders',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12, // Adjusted font size
                                color: currentTab == 2
                                    ? Colors.black
                                    : Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.popAndPushNamed(context, '/home');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2), // Adjusted padding
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.iron, color: Colors.white),
                            Text(
                              'Iron',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12, // Adjusted font size
                                  color: currentTab == 3
                                      ? Colors.white
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
