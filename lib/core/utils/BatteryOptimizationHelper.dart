import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Helper class to request battery optimization exemption
/// This is critical for background services to work properly
class BatteryOptimizationHelper {
  /// Request battery optimization exemption
  /// Returns true if already exempted or user granted exemption
  static Future<bool> requestBatteryOptimizationExemption() async {
    try {
      // Check if battery optimization is already ignored
      final status = await Permission.ignoreBatteryOptimizations.status;

      if (status.isGranted) {
        if (kDebugMode) print('✅ Battery optimization already exempted');
        return true;
      }

      // Request exemption
      if (kDebugMode) print('📱 Requesting battery optimization exemption...');
      final result = await Permission.ignoreBatteryOptimizations.request();

      if (result.isGranted) {
        if (kDebugMode) print('✅ Battery optimization exemption granted');
        return true;
      } else {
        if (kDebugMode) print('⚠️ Battery optimization exemption denied');
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error requesting battery optimization: $e');
      return false;
    }
  }

  /// Open battery optimization settings
  static Future<void> openBatteryOptimizationSettings() async {
    try {
      await Permission.ignoreBatteryOptimizations.request();
    } catch (e) {
      if (kDebugMode) print('❌ Error opening battery settings: $e');
    }
  }

  /// Check if battery optimization is enabled
  static Future<bool> isBatteryOptimizationEnabled() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      return !status.isGranted;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking battery optimization: $e');
      return true; // Assume enabled if we can't check
    }
  }
}