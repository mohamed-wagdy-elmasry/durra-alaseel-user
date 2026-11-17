import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controller/booking_controller.dart';

class MapLocationPickerScreen extends StatelessWidget {
  const MapLocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    final branch = controller.deliveryBranchInfo;

    final LatLng initialTarget =
        branch != null && (branch.latitude != 0.0 || branch.longitude != 0.0)
            ? LatLng(branch.latitude, branch.longitude)
            : const LatLng(24.7136, 46.6753);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Pickup Location'),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isCheckingDelivery.value
                    ? null
                    : () => _confirmAndPop(controller),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              )),
        ],
      ),
      body: Stack(
        children: [
          Obx(() => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 12,
                ),
                markers: controller.mapMarkers,
                circles: controller.mapCircles,
                onTap: (location) =>
                    controller.onDeliveryLocationSelected(location),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
              )),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _DeliveryStatusBanner(controller: controller),
          ),
        ],
      ),
    );
  }

  void _confirmAndPop(BookingController controller) {
    final result = controller.deliveryCheckResult.value;
    if (result?.allowed == true) {
      Get.back();
    } else {
      Get.snackbar(
        'Invalid Location',
        result?.statusMessage ?? 'Please select a valid delivery location.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class _DeliveryStatusBanner extends StatelessWidget {
  final BookingController controller;

  const _DeliveryStatusBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCheckingDelivery.value) {
        return _Banner(
          color: Colors.grey,
          icon: Icons.hourglass_top,
          message: 'Checking location...',
          subtitle: controller.selectedLocationAddress.value.isNotEmpty
              ? controller.selectedLocationAddress.value
              : null,
        );
      }

      final result = controller.deliveryCheckResult.value;
      if (result == null) {
        if (controller.selectedDeliveryLocation.value != null) {
          return _Banner(
            color: Colors.grey,
            icon: Icons.location_on,
            message: controller.selectedLocationAddress.value.isNotEmpty
                ? controller.selectedLocationAddress.value
                : 'Location selected',
          );
        }
        return const _Banner(
          color: Colors.blue,
          icon: Icons.touch_app,
          message: 'Tap the map to select your pickup location',
        );
      }

      return _Banner(
        color: result.allowed ? Colors.green : Colors.red,
        icon: result.allowed ? Icons.check_circle : Icons.cancel,
        message: result.statusMessage,
        subtitle: controller.selectedLocationAddress.value.isNotEmpty
            ? controller.selectedLocationAddress.value
            : null,
      );
    });
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;
  final String? subtitle;

  const _Banner({
    required this.color,
    required this.icon,
    required this.message,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color.withOpacity(0.9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
