import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:mesme/provider/provider.dart';
import 'package:mesme/screens/grocery.dart';
import 'package:mesme/screens/home.dart';
import 'package:mesme/screens/orders.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodBottomNavBar extends StatefulWidget {
  const FoodBottomNavBar({super.key});

  @override
  _FoodBottomNavBarState createState() => _FoodBottomNavBarState();
}

class _FoodBottomNavBarState extends State<FoodBottomNavBar> {
  void initState() {
    super.initState();
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    _fetchData(foodProvider);
  }

  Future<void> _fetchData(FoodProvider foodProvider) async {
    await foodProvider.fetchUserData();
    await foodProvider.fetchSavedAddress();
    await foodProvider.fetchOrders();
  }

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
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0), // Adjusted padding
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
                                ? Colors.orange.shade700
                                : Colors.black45,
                          ),
                          Text(
                            'Food',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12, // Adjusted font size
                                color: currentTab == 0
                                    ? Colors.orange.shade700
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
                                ? Colors.orange.shade700
                                : Colors.black45,
                          ),
                          Text(
                            'Grocery',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12, // Adjusted font size
                                color: currentTab == 1
                                    ? Colors.orange.shade700
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
                                ? Colors.orange.shade700
                                : Colors.black45,
                          ),
                          Text(
                            'Orders',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12, // Adjusted font size
                                color: currentTab == 2
                                    ? Colors.orange.shade700
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
                        _showComingSoonDialog(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2), // Adjusted padding
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
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

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.orange.shade700)),
                    color: Colors.white,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Image.asset(
                'images/iron.jpg', // Replace with your image URL
                width: 500,
                // height: 450,
              ),
              const SizedBox(height: 20),
              const Text(
                'Coming Soon!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
