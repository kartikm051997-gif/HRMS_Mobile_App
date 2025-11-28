import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../fonts/fonts.dart';
import '../constants/appcolor_dart.dart';

/// Mixin to track unsaved data and warn users when app closes
mixin UnsavedDataWarningMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  bool _hasUnsavedData = false;
  bool _isWarningShown = false;

  /// Override this method to check if there's unsaved data
  /// Return true if there's unsaved data that should trigger a warning
  bool hasUnsavedData() {
    return _hasUnsavedData;
  }

  /// Call this method to mark that there's unsaved data
  void markAsUnsaved() {
    if (!_hasUnsavedData) {
      _hasUnsavedData = true;
    }
  }

  /// Call this method to mark that data is saved
  void markAsSaved() {
    if (_hasUnsavedData) {
      _hasUnsavedData = false;
      _isWarningShown = false;
    }
  }

  /// Check if any text controllers have unsaved changes
  bool hasTextChanges(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      if (controller.text.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App is being minimized or going to background
      if (hasUnsavedData() && !_isWarningShown && mounted) {
        _isWarningShown = true;
        _showDataLossWarning();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App is back in foreground
      _isWarningShown = false;
    }
  }

  void _showDataLossWarning() {
    // Show warning dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: () async => false, // Prevent back button
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Unsaved Data',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'You have unsaved changes. If you close the app now, your data will not be saved. Please save your work before closing the app.',
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _isWarningShown = false;
                  },
                  child: Text(
                    'Continue Editing',
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      color: AppColor.primaryColor2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

/// Global app lifecycle observer

class AppLifecycleWarningObserver extends WidgetsBindingObserver {
  final BuildContext context;
  final bool Function()? checkUnsavedData;

  AppLifecycleWarningObserver({required this.context, this.checkUnsavedData});

  bool _isWarningShown = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Check if there's unsaved data
      final hasUnsaved = checkUnsavedData?.call() ?? false;

      if (hasUnsaved && !_isWarningShown) {
        _isWarningShown = true;
        _showWarningDialog();
      }
    } else if (state == AppLifecycleState.resumed) {
      _isWarningShown = false;
    }
  }

  void _showWarningDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Warning: Unsaved Data',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'You have unsaved changes in your form. If you close the app now, your data will not be saved. Please save your work before closing the app.',
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _isWarningShown = false;
                  },
                  child: Text(
                    'OK, I\'ll Save First',
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      color: AppColor.primaryColor2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
