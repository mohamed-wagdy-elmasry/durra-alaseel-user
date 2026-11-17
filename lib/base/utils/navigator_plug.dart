import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../maintenance/maintenance_dialog.dart';

/// Navigation helper for splash screen timing
/// Now simplified since language loading is synchronous
class NavigatorPlug {
  StreamSubscription<bool>? _maintenanceSubscription;
  bool _timerStarted = false;

  void startListening({
    required int seconds,
    required VoidCallback onChanged,
  }) {
    // Check maintenance status and navigate after delay
    _maintenanceSubscription =
        Get.find<SystemMaintenanceController>().maintenanceStatus.listen(
              (inMaintenance) {
            _checkStatus(seconds, onChanged);
          },
        );
    
    // Also trigger immediately in case maintenance is already checked
    _checkStatus(seconds, onChanged);
  }

  void _checkStatus(int seconds, VoidCallback onChanged) {
    if (!_timerStarted &&
        Get.find<SystemMaintenanceController>().maintenanceStatus.value ==
            false) {
      _timerStarted = true;

      Timer(
        Duration(seconds: seconds),
            () {
          if (Get.find<SystemMaintenanceController>().maintenanceStatus.value ==
              false) {
            _maintenanceSubscription?.cancel();
            onChanged();
          } else {
            _timerStarted = false;
          }
        },
      );
    }
  }

  void stopListening() {
    _maintenanceSubscription?.cancel();
  }
}