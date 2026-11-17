import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../../../backend/model/car_booking/pickup_location_model.dart';
import '../../../base/themes/token.dart';
import '../../../base/widgets/primary_button.dart';
import '../../../languages/strings.dart';

class MapPickerWidget extends StatefulWidget {
  final PickupLocation? initialLocation;
  final Function(PickupLocation) onLocationSelected;
  final LatLng? defaultCenter; // Branch location

  const MapPickerWidget({
    Key? key,
    this.initialLocation,
    required this.onLocationSelected,
    this.defaultCenter,
  }) : super(key: key);

  @override
  State<MapPickerWidget> createState() => _MapPickerWidgetState();
}

class _MapPickerWidgetState extends State<MapPickerWidget> {
  GoogleMapController? _mapController;
  LatLng _currentCenter = const LatLng(24.7136, 46.6753); // Default: Riyadh
  String _currentAddress = '';
  bool _isLoadingAddress = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // Priority: 1. Initial location, 2. Default center (branch), 3. User location
    if (widget.initialLocation != null && widget.initialLocation!.isValid) {
      setState(() {
        _currentCenter = LatLng(
          widget.initialLocation!.latitude,
          widget.initialLocation!.longitude,
        );
        _currentAddress = widget.initialLocation!.address;
      });
    } else if (widget.defaultCenter != null) {
      setState(() {
        _currentCenter = widget.defaultCenter!;
      });
      await _getAddressFromLatLng(_currentCenter);
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentCenter),
        );

        await _getAddressFromLatLng(_currentCenter);
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += address.isEmpty ? place.locality! : ', ${place.locality}';
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += address.isEmpty ? place.country! : ', ${place.country}';
        }

        setState(() {
          _currentAddress = address.isNotEmpty ? address : 'Unknown location';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _currentAddress = 'Unable to get address';
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);

        setState(() {
          _currentCenter = newPosition;
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(newPosition),
        );

        await _getAddressFromLatLng(newPosition);
      }
    } catch (e) {
      Get.snackbar(
        Strings.error.tr,
        Strings.locationNotFound.tr,
        backgroundColor: CustomColor.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      debugPrint('Error searching location: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentCenter = position.target;
    });
  }

  void _onCameraIdle() {
    _getAddressFromLatLng(_currentCenter);
  }

  Future<void> _confirmLocation() async {
    if (_currentAddress.isEmpty) {
      await _getAddressFromLatLng(_currentCenter);
    }

    final resolvedAddress = _currentAddress.isNotEmpty
        ? _currentAddress
        : Strings.locationNotFound.tr;
    PickupLocation selectedLocation = PickupLocation(
      latitude: _currentCenter.latitude,
      longitude: _currentCenter.longitude,
      address: resolvedAddress,
    );

    widget.onLocationSelected(selectedLocation);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.selectPickupLocation.tr),
        backgroundColor: CustomColor.primary,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 15.0,
            ),
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Center pin marker
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_pin,
                  size: 50,
                  color: CustomColor.primary,
                ),
                const SizedBox(height: 50), // Offset for visual center
              ],
            ),
          ),

          // Search bar at top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: Strings.searchLocation.tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onSubmitted: _searchLocation,
              ),
            ),
          ),

          // Address display and confirm button at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: CustomColor.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Selected Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _isLoadingAddress
                      ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Loading address...'),
                          ],
                        )
                      : Text(
                          _currentAddress.isNotEmpty
                              ? _currentAddress
                              : 'Move map to select location',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                  const SizedBox(height: 16),
                  _currentAddress.isNotEmpty && !_isLoadingAddress
                      ? PrimaryButton(
                          title: Strings.confirmLocation.tr,
                          onPressed: _confirmLocation,
                        )
                      : Opacity(
                          opacity: 0.5,
                          child: PrimaryButton(
                            title: Strings.confirmLocation.tr,
                            onPressed: () {},
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
