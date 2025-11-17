import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceVerificationProvider extends ChangeNotifier {
  bool _isVerified = false;
  String? _lastVerifiedDate;

  bool get isVerified => _isVerified;
  String? get lastVerifiedDate => _lastVerifiedDate;

  Future<void> initialize() async {
    await _loadVerificationStatus();
  }

  Future<bool> needsFaceVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final lastVerifiedDate = prefs.getString('last_face_verified_date');

      if (lastVerifiedDate == today) {
        if (kDebugMode) print('✅ Face already verified today');
        _isVerified = true;
        _lastVerifiedDate = lastVerifiedDate;
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        print('⚠️ Face verification needed (last: $lastVerifiedDate)');
      }
      _isVerified = false;
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking face verification: $e');
      return true; // Fail-safe: require verification
    }
  }

  Future<void> markFaceVerified() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.setString('last_face_verified_date', today);

      _isVerified = true;
      _lastVerifiedDate = today;
      notifyListeners();

      if (kDebugMode) print('✅ Marked face verified for: $today');
    } catch (e) {
      if (kDebugMode) print('❌ Error marking face verified: $e');
    }
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastVerifiedDate = prefs.getString('last_face_verified_date');

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _isVerified = _lastVerifiedDate == today;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error loading verification status: $e');
    }
  }

  Future<void> resetVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_face_verified_date');

      _isVerified = false;
      _lastVerifiedDate = null;
      notifyListeners();

      if (kDebugMode) print('🔄 Face verification reset');
    } catch (e) {
      if (kDebugMode) print('❌ Error resetting verification: $e');
    }
  }
}
