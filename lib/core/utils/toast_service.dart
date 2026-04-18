import 'dart:async';
import 'package:flutter/material.dart';
import 'package:edulearn/core/widgets/glass_toast.dart';

class ToastService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static OverlayEntry? _currentOverlay;
  static Timer? _timer;

  static void showSuccess(String message) {
    _showToast(message, ToastType.success);
  }

  static void showError(String message) {
    _showToast(message, ToastType.error);
  }

  static void showWarning(String message) {
    _showToast(message, ToastType.warning);
  }

  static void showInfo(String message) {
    _showToast(message, ToastType.info);
  }

  static void _showToast(String message, ToastType type) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    _currentOverlay?.remove();
    _timer?.cancel();

    _currentOverlay = OverlayEntry(
      builder: (context) => GlassToast(
        message: message,
        type: type,
        onDismiss: () => _hideToast(),
      ),
    );

    Navigator.of(context).overlay?.insert(_currentOverlay!);

    _timer = Timer(const Duration(seconds: 4), () {
      _hideToast();
    });
  }

  static void _hideToast() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _timer?.cancel();
    _timer = null;
  }
}
