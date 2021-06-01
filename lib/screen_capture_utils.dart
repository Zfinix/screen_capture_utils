import 'dart:async';

import 'package:flutter/services.dart';

class ScreenCaptureUtils {
  static const MethodChannel _channel = MethodChannel('screen_capture_utils');

  static const MethodChannel _dart_channel =
      MethodChannel('screen_capture_utils.dart');

  /// On Screen Captured Callback
  final void Function(String?)? onScreenCaptured;

  /// Callback for screen guarding status `(Android Only)`
  final void Function(bool)? isGuarding;

  /// On Screen Captured With Denied Permission `(Android Only)`
  final void Function()? onScreenCapturedWithDeniedPermission;

  ScreenCaptureUtils({
    this.onScreenCaptured,
    this.isGuarding,
    this.onScreenCapturedWithDeniedPermission,
  }) {
    _dart_channel.setMethodCallHandler(methodCallHandler);
  }

  /// Initialize plugin
  void intialize() async {
    await _channel.invokeMethod('initialize');
  }

  /// Guards the screen from screen capture `(Android only)`
  void guard() async {
    await _channel.invokeMethod('guard');
    if (isGuarding != null) isGuarding!(true);
  }

  /// Removes guard screen from screen capture `(Android only)`
  void unGuard() async {
    await _channel.invokeMethod('unGuard');
    if (isGuarding != null) isGuarding!(false);
  }

  /// Handle method calls for  screen capture utils callbacks
  Future methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onScreenCaptured':
        if (onScreenCaptured != null) {
          onScreenCaptured!(
            call.arguments != null ? call.arguments['path'] : '',
          );
        }
        return;
      case 'onScreenCapturedWithDeniedPermission':
        if (onScreenCapturedWithDeniedPermission != null) {
          onScreenCapturedWithDeniedPermission!();
        }
        return;
      default:
        throw MissingPluginException('not Implemented');
    }
  }
}
