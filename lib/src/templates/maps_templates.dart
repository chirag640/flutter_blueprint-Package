import 'package:path/path.dart' as p;
import '../config/blueprint_config.dart';

/// Generates Google Maps integration templates.
class MapsTemplates {
  /// Generates all maps-related files
  static Map<String, String> generate(BlueprintConfig config) {
    final files = <String, String>{};
    final appName = config.appName;

    files[p.join('lib', 'core', 'maps', 'map_service.dart')] =
        _mapService(appName);
    files[p.join('lib', 'core', 'maps', 'location_service.dart')] =
        _locationService(appName);
    files[p.join('lib', 'core', 'maps', 'geocoding_service.dart')] =
        _geocodingService(appName);
    files[p.join('lib', 'core', 'maps', 'marker_manager.dart')] =
        _markerManager(appName);
    files[p.join('lib', 'core', 'maps', 'map_utils.dart')] = _mapUtils(appName);

    return files;
  }

  /// Returns the dependencies required for maps
  static Map<String, String> getDependencies() {
    return {
      'google_maps_flutter': '^2.9.0',
      'geolocator': '^12.0.0',
      'geocoding': '^3.0.0',
    };
  }

  static String _mapService(String appName) => '''
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_service.dart';
import 'marker_manager.dart';

/// High-level service for Google Maps integration.
class MapService {
  MapService({
    LocationService? locationService,
  }) : _locationService = locationService ?? LocationService();

  final LocationService _locationService;
  GoogleMapController? _controller;
  final MarkerManager _markerManager = MarkerManager();

  /// Get the marker manager
  MarkerManager get markerManager => _markerManager;

  /// Set the map controller (call from onMapCreated)
  void setController(GoogleMapController controller) {
    _controller = controller;
  }

  /// Get current location and move camera there
  Future<LatLng?> goToCurrentLocation({double zoom = 15}) async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) return null;

    final latLng = LatLng(position.latitude, position.longitude);
    await animateCamera(latLng, zoom: zoom);
    return latLng;
  }

  /// Animate camera to a location
  Future<void> animateCamera(LatLng target, {double zoom = 15}) async {
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom),
    );
  }

  /// Move camera to a location (no animation)
  Future<void> moveCamera(LatLng target, {double zoom = 15}) async {
    await _controller?.moveCamera(
      CameraUpdate.newLatLngZoom(target, zoom),
    );
  }

  /// Zoom in
  Future<void> zoomIn() async {
    await _controller?.animateCamera(CameraUpdate.zoomIn());
  }

  /// Zoom out
  Future<void> zoomOut() async {
    await _controller?.animateCamera(CameraUpdate.zoomOut());
  }

  /// Fit bounds to show all markers
  Future<void> fitBounds({EdgeInsets padding = const EdgeInsets.all(50)}) async {
    final bounds = _markerManager.getBounds();
    if (bounds == null) return;

    await _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding.top),
    );
  }

  /// Get the current zoom level
  Future<double?> getZoomLevel() async {
    return await _controller?.getZoomLevel();
  }

  /// Get the visible region
  Future<LatLngBounds?> getVisibleRegion() async {
    return await _controller?.getVisibleRegion();
  }

  /// Take a snapshot of the map
  Future<dynamic> takeSnapshot() async {
    return await _controller?.takeSnapshot();
  }

  /// Create default map widget
  Widget buildMap({
    required CameraPosition initialPosition,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    Set<Polygon>? polygons,
    Set<Circle>? circles,
    MapType mapType = MapType.normal,
    bool myLocationEnabled = false,
    bool myLocationButtonEnabled = false,
    bool zoomControlsEnabled = true,
    bool compassEnabled = true,
    Function(LatLng)? onTap,
    Function(LatLng)? onLongPress,
    Function(CameraPosition)? onCameraMove,
    VoidCallback? onCameraIdle,
  }) {
    return GoogleMap(
      initialCameraPosition: initialPosition,
      markers: markers ?? _markerManager.markers,
      polylines: polylines ?? {},
      polygons: polygons ?? {},
      circles: circles ?? {},
      mapType: mapType,
      myLocationEnabled: myLocationEnabled,
      myLocationButtonEnabled: myLocationButtonEnabled,
      zoomControlsEnabled: zoomControlsEnabled,
      compassEnabled: compassEnabled,
      onMapCreated: setController,
      onTap: onTap,
      onLongPress: onLongPress,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
    );
  }

  /// Dispose of resources
  void dispose() {
    _controller = null;
  }
}
''';

  static String _locationService(String appName) => '''
import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Service for handling device location.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;

  /// Check if location services are enabled
  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  Future<LocationPermission> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Get current location
  Future<Position?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final permission = await checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get last known location (faster, but may be outdated)
  Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  /// Start listening to location updates
  Stream<Position> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calculate distance between two points (in meters)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Calculate bearing between two points (in degrees)
  double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Dispose of resources
  void dispose() {
    _positionSubscription?.cancel();
  }
}
''';

  static String _geocodingService(String appName) => '''
import 'package:geocoding/geocoding.dart';

/// Service for geocoding (address <-> coordinates).
class GeocodingService {
  /// Get address from coordinates (reverse geocoding)
  Future<Address?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      return Address(
        street: place.street ?? '',
        subLocality: place.subLocality ?? '',
        locality: place.locality ?? '',
        administrativeArea: place.administrativeArea ?? '',
        postalCode: place.postalCode ?? '',
        country: place.country ?? '',
        isoCountryCode: place.isoCountryCode ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  /// Get coordinates from address (forward geocoding)
  Future<Coordinates?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;

      final location = locations.first;
      return Coordinates(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get formatted address string from coordinates
  Future<String?> getFormattedAddress(
    double latitude,
    double longitude,
  ) async {
    final address = await getAddressFromCoordinates(latitude, longitude);
    return address?.formatted;
  }
}

/// Address model
class Address {
  const Address({
    required this.street,
    required this.subLocality,
    required this.locality,
    required this.administrativeArea,
    required this.postalCode,
    required this.country,
    required this.isoCountryCode,
  });

  final String street;
  final String subLocality;
  final String locality;
  final String administrativeArea;
  final String postalCode;
  final String country;
  final String isoCountryCode;

  /// Get formatted address string
  String get formatted {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (subLocality.isNotEmpty) parts.add(subLocality);
    if (locality.isNotEmpty) parts.add(locality);
    if (administrativeArea.isNotEmpty) parts.add(administrativeArea);
    if (postalCode.isNotEmpty) parts.add(postalCode);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  /// Get short address (street and locality only)
  String get shortAddress {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (locality.isNotEmpty) parts.add(locality);
    return parts.join(', ');
  }
}

/// Coordinates model
class Coordinates {
  const Coordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  String toString() => '(\$latitude, \$longitude)';
}
''';

  static String _markerManager(String appName) => '''
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Manages map markers.
class MarkerManager {
  final Map<MarkerId, Marker> _markers = {};

  /// Get all markers as a set
  Set<Marker> get markers => _markers.values.toSet();

  /// Get marker count
  int get count => _markers.length;

  /// Add a marker
  void addMarker({
    required String id,
    required LatLng position,
    String? title,
    String? snippet,
    BitmapDescriptor? icon,
    VoidCallback? onTap,
    Function(LatLng)? onDragEnd,
    bool draggable = false,
  }) {
    final markerId = MarkerId(id);
    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      icon: icon ?? BitmapDescriptor.defaultMarker,
      onTap: onTap,
      onDragEnd: onDragEnd,
      draggable: draggable,
    );
    _markers[markerId] = marker;
  }

  /// Remove a marker by ID
  void removeMarker(String id) {
    _markers.remove(MarkerId(id));
  }

  /// Clear all markers
  void clearMarkers() {
    _markers.clear();
  }

  /// Update marker position
  void updatePosition(String id, LatLng newPosition) {
    final markerId = MarkerId(id);
    final existing = _markers[markerId];
    if (existing != null) {
      _markers[markerId] = existing.copyWith(positionParam: newPosition);
    }
  }

  /// Get marker by ID
  Marker? getMarker(String id) {
    return _markers[MarkerId(id)];
  }

  /// Check if marker exists
  bool hasMarker(String id) {
    return _markers.containsKey(MarkerId(id));
  }

  /// Get bounds that contain all markers
  LatLngBounds? getBounds() {
    if (_markers.isEmpty) return null;

    double minLat = 90;
    double maxLat = -90;
    double minLng = 180;
    double maxLng = -180;

    for (final marker in _markers.values) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Create a custom marker icon from an asset
  static Future<BitmapDescriptor> createCustomIcon(
    String assetPath, {
    double width = 100,
  }) async {
    return await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(width, width)),
      assetPath,
    );
  }
}
''';

  static String _mapUtils(String appName) => '''
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utility functions for map calculations.
class MapUtils {
  /// Earth radius in meters
  static const double earthRadius = 6371000;

  /// Calculate distance between two points using Haversine formula (in meters)
  static double calculateDistance(LatLng from, LatLng to) {
    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);
    final dLat = _toRadians(to.latitude - from.latitude);
    final dLng = _toRadians(to.longitude - from.longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Format distance to readable string
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '\${meters.round()} m';
    } else {
      return '\${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Calculate bearing between two points (in degrees)
  static double calculateBearing(LatLng from, LatLng to) {
    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);
    final dLng = _toRadians(to.longitude - from.longitude);

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final bearing = math.atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  /// Get compass direction from bearing
  static String getCompassDirection(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Calculate center point of multiple coordinates
  static LatLng calculateCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);
    if (points.length == 1) return points.first;

    double x = 0;
    double y = 0;
    double z = 0;

    for (final point in points) {
      final lat = _toRadians(point.latitude);
      final lng = _toRadians(point.longitude);

      x += math.cos(lat) * math.cos(lng);
      y += math.cos(lat) * math.sin(lng);
      z += math.sin(lat);
    }

    final n = points.length;
    x /= n;
    y /= n;
    z /= n;

    final lng = math.atan2(y, x);
    final hyp = math.sqrt(x * x + y * y);
    final lat = math.atan2(z, hyp);

    return LatLng(_toDegrees(lat), _toDegrees(lng));
  }

  /// Check if a point is within a circle
  static bool isPointInCircle(LatLng point, LatLng center, double radiusMeters) {
    return calculateDistance(point, center) <= radiusMeters;
  }

  /// Calculate zoom level for a given distance
  static double getZoomLevel(double distance) {
    // Approximate zoom levels for different distances
    if (distance < 500) return 17;
    if (distance < 1000) return 16;
    if (distance < 2000) return 15;
    if (distance < 5000) return 14;
    if (distance < 10000) return 13;
    if (distance < 20000) return 12;
    if (distance < 50000) return 10;
    if (distance < 100000) return 9;
    return 8;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
  static double _toDegrees(double radians) => radians * 180 / math.pi;
}
''';
}
