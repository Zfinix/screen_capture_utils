import 'dart:async';

import 'package:flutter/services.dart';

class ScreenCaptureUtils {
  static const MethodChannel _channel = MethodChannel('screen_capture_utils');

  static const MethodChannel _dart_channel =
      MethodChannel('screen_capture_utils.dart');

  /// On Screen Captured Callback
  final void Function(bool) oniOSScreenCaptured;

  final void Function(String?) onScreenCaptured;

  /// Callback for screen guarding status
  final void Function(bool) guardingStatus;

  /// On Screen Captured With Denied Permission `(Android Only)`
  final void Function()? onScreenCapturedWithDeniedPermission;

  ScreenCaptureUtils({
    required this.onScreenCaptured,
    required this.oniOSScreenCaptured,
    required this.guardingStatus,
    this.onScreenCapturedWithDeniedPermission,
  }) {
    try {
      _dart_channel.setMethodCallHandler(methodCallHandler);
    } catch (e) {
      print(e.toString());
    }
  }

  /// Initialize plugin
  void intialize() async {
    await _channel.invokeMethod('initialize');
  }

  /// Guards the screen from screen capture `(Android only)`
  void guard() async {
    try {
      await _channel.invokeMethod('guard');
      guardingStatus(true);
    } catch (e) {
      print(e.toString());
    }
  }

  /// Removes guard screen from screen capture `(Android only)`
  void unGuard() async {
    await _channel.invokeMethod('unGuard');
    guardingStatus(false);
  }

  /// Handle method calls for screen capture utils callbacks
  Future<void> methodCallHandler(MethodCall call) async {
    try {
      switch (call.method) {
        case 'onIOSScreenCaptured':
          oniOSScreenCaptured(call.arguments);
          if (call.arguments) {
            guard();
          } else {
            unGuard();
          }
          break;
        case 'onScreenCaptured':
          onScreenCaptured(
            call.arguments != null ? call.arguments['path'] : '',
          );
          break;
        case 'onScreenCapturedWithDeniedPermission':
          if (onScreenCapturedWithDeniedPermission != null) {
            onScreenCapturedWithDeniedPermission!();
          }
          break;
        default:
          throw MissingPluginException('not Implemented');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
