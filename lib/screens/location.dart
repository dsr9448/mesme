import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mesme/provider/provider.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class MeLocation extends StatefulWidget {
  final String uid;
  final back; // Define the parameter to be passed

  const MeLocation({Key? key, required this.uid, this.back}) : super(key: key);

  @override
  State<MeLocation> createState() => _MeLocationState();
}

class _MeLocationState extends State<MeLocation> {
  TextEditingController _locationController = TextEditingController();
  Position? _currentPosition;
  late double latitude;
  late double longitude;
  late String savedAddress = '';
  bool _isLoading = false; // Add a bool to track loading state

  @override
  void initState() {
    super.initState();
    fetchSavedAddress();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: widget.back == true
            ? SizedBox()
            : IconButton(
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
          'Enter Your Location',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading // Conditional rendering based on loading state
          ? const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.orange,
                color: Colors.white,
              ),
            )
          : Container(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () {
                        _getLocation().whenComplete(() {
                          updateLocation(latitude, longitude);
                        }); // Trigger location retrieval
                      },
                      icon: const Icon(
                        Icons.location_searching_sharp,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      label: const Text(
                        'Use my current location',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'Saved Address',
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.black, letterSpacing: 2.2),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  ListTile(
                    title: const Text('saved Location'),
                    subtitle: Text(savedAddress.isNotEmpty
                        ? savedAddress
                        : 'No address saved'),
                    tileColor: Colors.orange.shade700,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: _buildSnackBarContent(),
                        showCloseIcon: true,
                        duration: Duration(seconds: 2),
                      ));
                      Navigator.pop(context);
                    },
                    textColor: Colors.white,
                    leading: const Icon(Icons.pin_drop_rounded),
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildSnackBarContent() {
    if (savedAddress.isNotEmpty) {
      return Text('Location selected: $savedAddress');
    } else {
      return Text('No address saved');
    }
  }

  _getLocation() async {
    setState(() {
      _isLoading = true; // Set loading state to true while fetching location
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() {
            _isLoading =
                false; // Set loading state to false if permission denied
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;
        latitude = position.latitude;
        longitude = position.longitude;
        _updateLocationTextField(placemarks.first);
        _isLoading = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateLocationTextField(Placemark placemark) {
    if (placemark != null) {
      String address = '';
      address += placemark.street ?? '';
      address += ', ' + (placemark.subLocality ?? '');
      address += ', ' + (placemark.locality ?? '');
      address += ', ' + (placemark.administrativeArea ?? '');
      address += ', ' + (placemark.country ?? '');
      address += ', ' + (placemark.postalCode ?? '');
      _locationController.text = address;
    } else {
      _locationController.text = 'Unable to fetch location';
    }
  }

  Future<void> fetchSavedAddress() async {
    try {
      var url = 'https://mesme.in/admin/api/users/get.php?id=${widget.uid}';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        setState(() {
          savedAddress = userData['address'] ?? '';
          // savedAddress = userData['address'] ?? '';
        });
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching saved address: $e");
    }
  }

  void updateLocation(double latitude, double longitude) async {
    try {
      var updateUrl = 'https://mesme.in/admin/api/location/location.php';
      var body = {
        'id': widget.uid,
        'address': _locationController.text,
        'location': '$latitude,$longitude'
      };
      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      var response = await http.post(
        Uri.parse(updateUrl),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        Provider.of<FoodProvider>(context, listen: false).fetchSavedAddress();
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
            'Location updated successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          duration: const Duration(seconds: 2),
        ));
      } else {
        throw Exception('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      print("Error updating location: $e");
    }
  }
}
