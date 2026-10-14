import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class LocationHelper {
  static const String fallbackAddress = 'Mogadishu, Somalia';

  static Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
    String fallback = fallbackAddress,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return fallback;
      }

      final place = placemarks.first;

      final address = [
        place.street,
        place.locality,
        place.administrativeArea,
        place.country,
      ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');

      return address.isNotEmpty ? address : fallback;
    } catch (_) {
      return fallback;
    }
  }

  LatLng? toLatLng(List<double>? coordinates) {
    if (coordinates == null || coordinates.length < 2) {
      return null;
    }

    final longitude = coordinates[0];
    final latitude = coordinates[1];

    if (latitude < -90 || latitude > 90) return null;
    if (longitude < -180 || longitude > 180) return null;

    return LatLng(latitude, longitude);
  }
}
