import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371.0; // Earth's radius in kilometers

  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = R * c;
  return distance;
}

// Convert degrees to radians
double _toRadians(double degree) {
  return degree * pi / 180;
}

Map<String, dynamic> isWithin6Km(String coord1, String coord2) {
  List<String> coords1 = coord1.split(',');
  List<String> coords2 = coord2.split(',');

  double lat1 = double.parse(coords1[0]);
  double lon1 = double.parse(coords1[1]);
  double lat2 = double.parse(coords2[0]);
  double lon2 = double.parse(coords2[1]);

  double distance = calculateDistance(lat1, lon1, lat2, lon2);
  double roundedDistance =
      double.parse(distance.toStringAsFixed(2)); // Round to 2 decimal places
  bool isWithinRange = roundedDistance <= 6.0;
  print('this is test, $isWithinRange, $roundedDistance');

  return {'isWithinRange': isWithinRange, 'distance': roundedDistance};
}
