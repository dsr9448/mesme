import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mesme/models/food_item.dart';
import 'package:mesme/models/grocery_model.dart';
import 'package:mesme/models/ordermodel.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mesme/widgets/calculateLocation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class FoodProvider with ChangeNotifier {
  List<Restaurant> restaurants = [];
  List<String> bannerImages = [];
  List<Grocery> groceries = [];
  List<Order> orders = [];
  User? user = FirebaseAuth.instance.currentUser;
  UserModel? userData;
  Map<int, List<GroceryItem>> groceryCategoriesMap = {};
  bool isLoading = true;
  bool isAuthInProgress = false;
  Timer? _timer;
  bool _dataFetched = false;
  late Razorpay _razorpay;
  String? _currentOrderId;

  FoodProvider() {
    fetchUserData();
    fetchSavedCoordinates();
    fetchSavedAddress();
    fetchRestaurants();
    fetchGrocery();
    fetchOrders();
    _startPeriodicFetch();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isAuthInProgress = false;
  bool _passwordVisible = false;

  bool get isPasswordVisible => _passwordVisible;

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  Future<void> signUp(
      String name, String email, String phoneNumber, String password) async {
    _isAuthInProgress = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await http.post(
          Uri.parse('https://mesme.in/admin/api/users/create.php'),
          body: {
            "id": user.uid,
            "name": name,
            "email": email,
            "phoneNumber": phoneNumber,
            "profilePhoto": '',
            "password": password,
            "address": '',
          },
        );
      }
    } catch (e) {
      // Handle errors, e.g., show error message
    } finally {
      _isAuthInProgress = false;
      notifyListeners();
    }
  }

  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      isAuthInProgress = true;
      notifyListeners(); // Notify UI to show a loading indicator

      // Sign in with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;

      if (user != null) {
        // Fetch necessary data once the user logs in
        await fetchUserData();
        await fetchSavedCoordinates();
        await fetchSavedAddress();
        await fetchRestaurants();
        await fetchGrocery();
        await fetchOrders();

        isAuthInProgress = false;
        notifyListeners();
        return user; // Return the authenticated user
      } else {
        isAuthInProgress = false;
        notifyListeners();
        return null;
      }
    } on FirebaseAuthException catch (e) {
      isAuthInProgress = false;
      notifyListeners(); // Notify UI to stop loading indicator
      // print('Login failed: $e');
      return null;
    } catch (e) {
      isAuthInProgress = false;
      notifyListeners();
      // print('Error logging in: $e');
      return null;
    }
  }
Future<User?> signUpWithEmailAndPassword(
    String name, String email, String phoneNumber, String password) async {
  try {
    isAuthInProgress = true;
    notifyListeners(); // Notify UI to show a loading indicator

    // Firebase sign-up process
    
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email:email,password: password);
    User? user = userCredential.user;


    if (user != null) {
      // Store user information in your backend server
      var res = await http.post(
        Uri.parse('https://mesme.in/admin/api/users/create.php'),
        body: {
          "id": user.uid,
          "name": name,
          "email": email,
          "phoneNumber": phoneNumber,
          "profilePhoto": '',
          "password": password,
          "address": '',
        },
      );

      if (res.statusCode == 200) {
        // Fetch user data and relevant information
       
        await fetchRestaurants();
        await fetchGrocery();

        isAuthInProgress = false;
        notifyListeners();
        return user; // Return the signed-up user
      } else {
        throw Exception('Failed to create user: ${res.statusCode}');
      }
    } else {
      isAuthInProgress = false;
      notifyListeners();
      return null; // Sign-up failed
    }
  } on FirebaseAuthException catch (e) {
    isAuthInProgress = false;
    notifyListeners();
    print('Sign-up failed: $e');
    return null;
  } catch (e) {
    isAuthInProgress = false;
    notifyListeners();
    print('Error during sign-up: $e');
    return null;
  }
}

  Future<void> fetchRestaurants() async {
    await fetchUserData();
    if (_dataFetched) return;
    if (restaurants.isNotEmpty) return;

    String? address = await fetchSavedCoordinates();
    final response =
        await http.get(Uri.parse('https://mesme.in/admin/api/Food/get.php'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      List<Restaurant> fetchedRestaurants = (jsonData['restaurants'] as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();

      String userCoordinate = userData!.location ?? address ?? '0,0';

      // List to hold restaurants with distances
      List<Map<String, dynamic>> restaurantWithDistances = [];

      // Calculate distances for each restaurant1
      for (var restaurant in fetchedRestaurants) {
        String restaurantCoordinate = restaurant
            .coordinates; // Assuming restaurant coordinates are a string

        // Use the isWithin6Km function to calculate the distance
        Map<String, dynamic> result =
            isWithin6Km(userCoordinate, restaurantCoordinate);
        double distance = result['distance']; // Get the calculated distance

        // Store the restaurant and its distance
        restaurantWithDistances.add({
          'restaurant': restaurant,
          'distance': distance,
        });
      }

      // Sort restaurants by distance (ascending)
      restaurantWithDistances
          .sort((a, b) => a['distance'].compareTo(b['distance']));

      // Extract the sorted restaurants and cast them as List<Restaurant>
      restaurants = restaurantWithDistances
          .map<Restaurant>((item) => item['restaurant'] as Restaurant)
          .toList();

      // Banner images (if needed)
      bannerImages = List<String>.from(jsonData['bannerImages']);
      _dataFetched = true;
      notifyListeners();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<void> fetchGrocery() async {
    // if (_dataFetched) return;
    if (groceries.isNotEmpty) return;
    await fetchUserData();
    String? address = await fetchSavedCoordinates();
    final response = await http
        .get(Uri.parse('https://mesme.in/admin/api/Food/getGrocery.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<Map<String, dynamic>> groceryWithDistances = [];
      final Map<int, List<GroceryItem>> loadedCategoriesMap = {};

      // User location (assumed to be in 'lat,long' format)
      String userCoordinate = userData!.location ?? address ?? '0,0';

      // Parse categories and calculate distance
      for (var categoryJson in data['categories']) {
        final category = Grocery.fromJson(categoryJson);
        String groceryCoordinate = category
            .coordinates; // Assuming coordinates exist for each category

        // Calculate distance using isWithin6Km
        Map<String, dynamic> result =
            isWithin6Km(userCoordinate, groceryCoordinate);
        double distance = result['distance']; // Get the calculated distance

        // Add the grocery category along with its distance
        groceryWithDistances.add({
          'grocery': category,
          'distance': distance,
        });

        loadedCategoriesMap[category.id] = [];

        // Parse items for each category
        for (var itemJson in categoryJson['items']) {
          final item = GroceryItem.fromJson(itemJson);
          loadedCategoriesMap[category.id]?.add(item);
        }
      }

      // Sort grocery categories by distance (ascending order)
      groceryWithDistances
          .sort((a, b) => a['distance'].compareTo(b['distance']));

      // Extract sorted grocery categories
      groceries = groceryWithDistances
          .map<Grocery>((item) => item['grocery'] as Grocery)
          .toList();

      // Assign the loaded categories map
      groceryCategoriesMap = loadedCategoriesMap;
      _dataFetched = true;
      notifyListeners();
    } else {
      throw Exception('Failed to load groceries');
    }
  }

  Future<void> fetchUserData() async {
    try {
      if (user == null) {
        throw Exception('User is not authenticated');
      }

      var url = 'https://mesme.in/admin/api/users/get.php?id=${user!.uid}';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userData = UserModel.fromMap(data);
        fetchSavedAddress();
        notifyListeners();
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> fetchSavedAddress() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not authenticated');
      }
      var url = 'https://mesme.in/admin/api/users/get.php?id=${user.uid}';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);

        notifyListeners();
        return userData['address'] ?? '';
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching saved address: $e");
      return null;
    }
  }

  Future<String?> fetchSavedCoordinates() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not authenticated');
      }
      var url = 'https://mesme.in/admin/api/users/get.php?id=${user.uid}';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);

        notifyListeners(); // Notify listeners when the address is updated
        return userData['location'] ?? ''; // Return the saved address
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching saved address: $e");
      return null; // Return null in case of error
    }
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse(
        'https://mesme.in/admin/api/FoodOrders/get.php?userId=${user!.uid}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<dynamic> orderList = data['orders'];
        orders = orderList.map((orderData) {
          return Order.fromMap(orderData);
        }).toList();
        notifyListeners();
        print('fetching');
      } else {
        throw Exception('Failed to load orders: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> openCheckout(
    double totalAmount,
    String Description,
    String orderId,
  ) async {
    _currentOrderId = orderId;
    print(
        'this is razorpay: $totalAmount, $Description, ${userData!.email}, ${userData!.phoneNumber}');
    var options = {
      // 'key': 'rzp_live_XUVo3h4lBdfxh0',
      'key': 'rzp_test_4dYa1o2CgjiMJ1',
      'amount': totalAmount * 100,
      'name': userData!.name,
      'description': Description,
      'prefill': {'contact': userData!.phoneNumber, 'email': userData!.email},
      'theme': {
        'color': '#F47C20',
        'button_color': '#F47C20',
        'text_color': 'white'
      },
      // 'order_id': orderId,
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentOrderId != null) {
      await updatePayment(_currentOrderId!, "Paid");
      // Use the stored orderId
    } else {
      print('Error: orderId is null');
    }
    notifyListeners();
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    print("Payment Failed: ${response.code} - ${response.message}");
    if (_currentOrderId != null) {
      await updatePayment(_currentOrderId!, "Failed"); // Use the stored orderId
    } else {
      print('Error: orderId is null');
    }
    notifyListeners();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
    notifyListeners();
  }

  void _startPeriodicFetch() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await fetchOrders();
    });
  }

  Future<void> updatePayment(String orderId, String status) async {
    // Data to be sent as JSON
    Map<String, dynamic> requestData = {
      'orderId': orderId,
      'status': status,
      'paymentMethod': 'Online'
    };

    try {
      // Sending the request to the server
      final response = await http.post(
        Uri.parse('https://mesme.in/admin/api/FoodPayments/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      // Checking the response status code
      if (response.statusCode == 200) {
        // If the server returns a response with a 200 status code, parse the JSON
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        notifyListeners();
        // Handle the response from the server
        if (responseBody['error'] != null) {
          // Handle error case

          print('Error: ${responseBody['error']}');
        } else {
          // Success case
          print('Success: ${responseBody['message']}');
        }
      } else {
        // Handle non-200 responses
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      print('Request error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
