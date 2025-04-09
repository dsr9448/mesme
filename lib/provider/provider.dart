import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:mesme/models/food_item.dart';
import 'package:mesme/models/grocery_model.dart';
import 'package:mesme/models/ordermodel.dart';
import 'package:mesme/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mesme/services/firebase_authservices.dart';
import 'package:mesme/widgets/calculateLocation.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class FoodProvider with ChangeNotifier {
  List<Restaurant> restaurants = [];
  List<Restaurant> restaurant = [];
  List<Restaurant> restaurantsAbove4 = [];
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
  BuildContext? _tempContext;
  final FirebaseAuthServices auth = FirebaseAuthServices();
  Map<String, Future<dynamic>> _pendingRequests = {};
  DateTime? _lastUserDataFetch;
  DateTime? _lastRestaurantFetch;
  DateTime? _lastOrderFetch;

  FoodProvider() {
    _initializeData();
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

  Future<void> _initializeData() async {
    await Future.wait([
      fetchUserData(),
      fetchSavedCoordinates(),
      fetchSavedAddress(),
      fetchRestaurants(),
      fetchOrders(),
      fetchWishlist(),
    ]);
  }

  Future<dynamic> _deduplicateRequest(
      String key, Future<dynamic> Function() request) async {
    if (_pendingRequests.containsKey(key)) {
      return _pendingRequests[key];
    }

    final future = request();
    _pendingRequests[key] = future;

    try {
      final result = await future;
      _pendingRequests.remove(key);
      return result;
    } catch (e) {
      _pendingRequests.remove(key);
      rethrow;
    }
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
          Uri.parse(
              'https://mesme.inkaradigital.com/admin/api/users/create.php'),
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
        await fetchWishlist();
        // await fetchGrocery();
        await fetchOrders();

        isAuthInProgress = false;
        notifyListeners();
        return user; // Return the authenticated user
      } else {
        isAuthInProgress = false;
        notifyListeners();
        return null;
      }
    } on FirebaseAuthException {
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

      // UserCredential userCredential = await FirebaseAuth.instance
      //     .signInWithEmailAndPassword(email:email,password: password);
      // User? user = userCredential.user;
      User? user = await auth.signupWithEmailandPassword(email, password);

      if (user != null) {
        // Store user information in your backend server
        var res = await http.post(
          Uri.parse(
              'https://mesme.inkaradigital.com/admin/api/users/create.php'),
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

          // await fetchRestaurants();
          // await fetchGrocery();

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
    if (_lastRestaurantFetch != null &&
        DateTime.now().difference(_lastRestaurantFetch!) <
            Duration(minutes: 1)) {
      return;
    }

    return _deduplicateRequest('fetchRestaurants', () async {
      String? address = await fetchSavedCoordinates();
      final response = await http.get(
          Uri.parse('https://mesme.inkaradigital.com/admin/api/Food/get.php'));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        List<Restaurant> fetchedRestaurants = (jsonData['restaurants'] as List)
            .map((json) => Restaurant.fromJson(json))
            .toList();

        List<Restaurant> fetchedRestaurantsAbove4 = fetchedRestaurants
            .where((restaurant) => double.parse(restaurant.rating ?? "0.0") > 4)
            .toList();

        String userCoordinate = userData!.location ?? address ?? '0,0';

        List<Map<String, dynamic>> calculateDistances(
            List<Restaurant> restaurantList) {
          return restaurantList.map((restaurant) {
            String restaurantCoordinate = restaurant.coordinates;
            double rating = double.parse(restaurant.rating ?? "0.0");
            Map<String, dynamic> result =
                isWithin6Km(userCoordinate, restaurantCoordinate);
            double distance = result['distance'];
            return {
              'restaurant': restaurant,
              'distance': distance,
              'rating': rating,
            };
          }).toList();
        }

        List<Map<String, dynamic>> restaurantWithDistances =
            calculateDistances(fetchedRestaurants);
        List<Map<String, dynamic>> restaurantAbove4WithDistances =
            calculateDistances(fetchedRestaurantsAbove4);

        restaurantWithDistances
            .sort((a, b) => a['distance'].compareTo(b['distance']));
        restaurantAbove4WithDistances
            .sort((a, b) => b['rating'].compareTo(a['rating']));

        restaurants = restaurantWithDistances
            .map<Restaurant>((item) => item['restaurant'] as Restaurant)
            .toList();

        restaurantsAbove4 = restaurantAbove4WithDistances
            .map<Restaurant>((item) => item['restaurant'] as Restaurant)
            .toList();

        bannerImages = List<String>.from(jsonData['bannerImages']);
        _lastRestaurantFetch = DateTime.now();
        notifyListeners();
      } else {
        throw Exception('Failed to load restaurants');
      }
    });
  }

  Future<void> fetchWishlist() async {
    String? address = await fetchSavedCoordinates();
    final response = await http.get(Uri.parse(
        'https://mesme.inkaradigital.com/admin/api/Wishlist/get.php?userid=${user!.uid}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      List<dynamic> restaurantList = jsonData['restaurants'] ?? [];

      if (restaurantList is! List) {
        throw Exception('Invalid data format for restaurants');
      }

      List<Restaurant> fetchedRestaurants =
          restaurantList.map((json) => Restaurant.fromJson(json)).toList();

      String userCoordinate = userData!.location ?? address ?? '0,0';

      // List to hold restaurants with distances
      List<Map<String, dynamic>> restaurantWithDistances = [];

      // Calculate distances for each restaurant
      for (var restaurant in fetchedRestaurants) {
        String restaurantCoordinate = restaurant.coordinates;

        // Use the isWithin6Km function to calculate the distance
        Map<String, dynamic> result =
            isWithin6Km(userCoordinate, restaurantCoordinate);
        double distance = result['distance'];

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
      restaurant = restaurantWithDistances
          .map<Restaurant>((item) => item['restaurant'] as Restaurant)
          .toList();

      notifyListeners();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<void> addToWishlist(int foodId) async {
    final url = 'https://mesme.inkaradigital.com/admin/api/Wishlist/create.php';

    final requestData = {
      'userid': FirebaseAuth.instance.currentUser!.uid,
      'foodid': foodId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('message') ||
            responseData.containsKey('error')) {
          await fetchRestaurants();
          await fetchWishlist();
          notifyListeners();
        }
      } else {
        await fetchWishlist();
        await fetchRestaurants();
        notifyListeners();
      }
    } catch (error) {
      print('Network error: $error');
    }

    notifyListeners();
  }

  Future<void> removeFromWishlist(int foodId) async {
    final url = 'https://mesme.inkaradigital.com/admin/api/Wishlist/delete.php';

    final requestData = {
      'userid': FirebaseAuth.instance.currentUser!.uid,
      'foodid': foodId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('message') ||
            responseData.containsKey('error')) {
          await fetchRestaurants();
          await fetchWishlist();
          notifyListeners();
        }
      } else {
        await fetchWishlist();
        await fetchRestaurants();
        notifyListeners();
      }
    } catch (error) {
      print('Network error: $error');
    }

    notifyListeners();
  }

  Future<void> fetchGrocery() async {
    if (groceries.isNotEmpty) return;
    await fetchUserData();
    String? address = await fetchSavedCoordinates();
    final response = await http.get(Uri.parse(
        'https://mesme.inkaradigital.com/admin/api/Food/getGrocery.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<Map<String, dynamic>> groceryWithDistances = [];
      final Map<int, List<GroceryItem>> loadedCategoriesMap = {};

      String userCoordinate = userData?.location ?? address ?? '0,0';

      for (var categoryJson in data['categories']) {
        final category = Grocery.fromJson(categoryJson);
        String groceryCoordinate = category.coordinates;

        Map<String, dynamic> result =
            isWithin6Km(userCoordinate, groceryCoordinate);
        double distance = result['distance'];

        groceryWithDistances.add({
          'grocery': category,
          'distance': distance,
        });

        loadedCategoriesMap[category.id] = [];

        for (var itemJson in categoryJson['items']) {
          final item = GroceryItem.fromJson(itemJson);
          loadedCategoriesMap[category.id]?.add(item);
        }
      }

      groceryWithDistances
          .sort((a, b) => a['distance'].compareTo(b['distance']));

      groceries = groceryWithDistances
          .map<Grocery>((item) => item['grocery'] as Grocery)
          .toList();

      groceryCategoriesMap = loadedCategoriesMap;
      _dataFetched = true;
      notifyListeners();
    }
  }

  Future<void> fetchUserData() async {
    if (_lastUserDataFetch != null &&
        DateTime.now().difference(_lastUserDataFetch!) < Duration(minutes: 1)) {
      return;
    }

    return _deduplicateRequest('fetchUserData', () async {
      try {
        user = _auth.currentUser;
        if (user == null) {
          throw Exception('User is not authenticated');
        }

        var url =
            'https://mesme.inkaradigital.com/admin/api/users/get.php?id=${user!.uid}';
        var response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          userData = UserModel.fromMap(data);
          _lastUserDataFetch = DateTime.now();
          notifyListeners();
        } else {
          throw Exception('Failed to load user data: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching user data: $e');
      }
    });
  }

  Future<String?> fetchSavedAddress() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not authenticated');
      }
      var url =
          'https://mesme.inkaradigital.com/admin/api/users/get.php?id=${user.uid}';
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
      var url =
          'https://mesme.inkaradigital.com/admin/api/users/get.php?id=${user.uid}';
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

  Future<void> updateToken() async {
    try {
      // Get the current authenticated user
      User? user = FirebaseAuth.instance.currentUser;

      // Check if user is authenticated
      if (user == null) {
        throw Exception('User is not authenticated');
      }

      // Retrieve the Firebase token
      String? token = await FirebaseMessaging.instance.getToken();

      // Check if token is retrieved successfully
      if (token == null) {
        throw Exception('Unable to retrieve Firebase token');
      }

      // Define the API URL for updating the token
      var url = Uri.parse(
          'https://mesme.inkaradigital.com/admin/api/users/updateToken.php');

      // Send POST request to the API
      var response = await http.post(
        url,
        body: {
          'id': user.uid, // Pass the user ID as 'id'
          'token': token, // Pass the Firebase token as 'token'
        },
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        print('Token updated successfully');
      } else {
        throw Exception('Failed to update token: ${response.statusCode}');
      }
    } catch (e) {
      // Print error if updating token fails
      print("Error updating token: $e");
    }
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse(
        'https://mesme.inkaradigital.com/admin/api/FoodOrders/get.php?userId=${user!.uid}'));

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
    BuildContext context,
  ) async {
    _tempContext = context;
    _currentOrderId = orderId;
    print(
        'this is razorpay: $totalAmount, $Description, ${userData!.email}, ${userData!.phoneNumber}');
    var options = {
      // 'key': 'rzp_live_XUVo3h4lBdfxh0',
      'key': 'rzp_live_XUVo3h4lBdfxh0',
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
      await updatePayment(_currentOrderId!, "Paid").whenComplete(() {
        if (_tempContext != null && _tempContext!.mounted) {
          // Safe navigation after checking if the context is still valid
          Navigator.pushNamedAndRemoveUntil(
            _tempContext!,
            '/home',
            (Route<dynamic> route) => false,
          );

          QuickAlert.show(
              context: _tempContext!,
              type: QuickAlertType.success,
              title: 'Payment Successful',
              confirmBtnColor: Colors.orange.shade700,
              text: 'Transaction Completed Successfully!',
              autoCloseDuration: Duration(seconds: 3),
              showConfirmBtn: false);
          Future.delayed(Duration(seconds: 3), () {
            if (_tempContext != null && Navigator.canPop(_tempContext!)) {
              Navigator.pop(_tempContext!);
            }
          });
        }
      });

      // Show success message after successful payment
    } else {
      print('Error: orderId is null');
    }
    _tempContext = null; // Clear context after use
    notifyListeners();
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    if (_currentOrderId != null) {
      await updatePayment(_currentOrderId!, "Failed").whenComplete(() {
        if (_tempContext != null && _tempContext!.mounted) {
          // Safe navigation after checking if the context is still valid
          Navigator.pushNamedAndRemoveUntil(
            _tempContext!,
            '/home',
            (Route<dynamic> route) => false,
          );

          // Show the QuickAlert in a safe context
          QuickAlert.show(
            context: _tempContext!,
            type: QuickAlertType.error,
            title: 'Payment Failed',
            confirmBtnColor: Colors.red,
            text: 'Transaction Failed. Please try again.',
            autoCloseDuration: Duration(seconds: 1),
            showConfirmBtn: false,
          );

          // Close the QuickAlert dialog after 3 seconds if the context is still valid
          Future.delayed(Duration(seconds: 3), () {
            if (_tempContext != null && Navigator.canPop(_tempContext!)) {
              Navigator.pop(_tempContext!);
            }
          });
        }
      });
    } else {
      print('Error: orderId is null');
    }

    _tempContext = null;
    notifyListeners();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
    notifyListeners();
  }

  void _startPeriodicFetch() {
    // _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
    //   await fetchOrders();
    // });
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
        Uri.parse(
            'https://mesme.inkaradigital.com/admin/api/FoodPayments/update.php'),
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

  Future<Map<String, dynamic>> createOrder(
    String userId,
    String rid,
    String status,
    String deliveryAddress,
    double totalPrice,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://mesme.inkaradigital.com/admin/api/FoodOrders/create.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
        body: jsonEncode({
          'userId': userId,
          'partnerId': rid,
          'status': status,
          'deliveryAddress': deliveryAddress,
          'totalPrice': totalPrice.toString(),
          'items': items,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await fetchOrders(); // Refresh orders list after creating new order
        notifyListeners();
        return responseData;
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }
}
