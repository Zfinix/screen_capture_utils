import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:screen_capture_utils/screen_capture_utils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String path = 'Unknown';
  bool guarding = false;
  late ScreenCaptureUtils screenCaptureUtils;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      screenCaptureUtils = ScreenCaptureUtils(
        onScreenCaptured: (_) {
          print('Captured: $_');
        },
        isGuarding: (val) {
          setState(() {
            guarding = val;
          });
        },
        onScreenCapturedWithDeniedPermission: () {
          var msg = 'onScreenCapturedWithDeniedPermission';
          print('$msg');
          setState(() {
            path = msg;
          });
        },
      )..intialize();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(path),
              SizedBox(
                height: 40,
              ),
              guarding == false
                  ? CupertinoButton.filled(
                      onPressed: () {
                        screenCaptureUtils.guard();
                      },
                      child: Text('Guard'),
                    )
                  : CupertinoButton.filled(
                      onPressed: () {
                        /// Guard Screen
                        screenCaptureUtils.guard();

                        /// Unguard Screen
                        screenCaptureUtils.unGuard();
                      },
                      child: Text('UnGuard'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}