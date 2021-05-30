// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:flutter/services.dart';

class ScreenCaptureUtils {
  static const MethodChannel _channel = MethodChannel('screen_capture_utils');

  static const MethodChannel _dart_channel =
      MethodChannel('screen_capture_utils.dart');

  final void Function(String?)? onScreenCaptured;
  final void Function(bool)? isGuarding;
  final void Function()? onScreenCapturedWithDeniedPermission;

  ScreenCaptureUtils({
    this.onScreenCaptured,
    this.isGuarding,
    this.onScreenCapturedWithDeniedPermission,
  }) {
    _dart_channel.setMethodCallHandler(methodCallHandler);
  }

  void intialize() async {
    await _channel.invokeMethod('initialize');
  }

  void guard() async {
    await _channel.invokeMethod('guard');
    if (isGuarding != null) isGuarding!(true);
  }

  void unGuard() async {
    await _channel.invokeMethod('unGuard');
    if (isGuarding != null) isGuarding!(false);
  }

  Future methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onScreenCaptured':
        if (onScreenCaptured != null) {
          try {
            onScreenCaptured!(
              call.arguments != null ? call.arguments['path'] : '',
            );
          } catch (e) {
            print(e.toString());
          }
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
