# Screen Capture Utils
A plugin to handle screen capture events on android and ios

### 🚀 Initialize SDK

```dart
  late ScreenCaptureUtils screenCaptureUtils;
  
  ...   
    
  screenCaptureUtils = ScreenCaptureUtils(
      // Path returns empty on iOS
      onScreenCaptured: (_) {
          print('Captured: $_');
      },
    
      /// Only on Android !!!
      isGuarding: (bool val) {
        print(val);
      },
    
      /// Only on Android !!!
      onScreenCapturedWithDeniedPermission: () {
        print('onScreenCapturedWithDeniedPermission');
      },
  )..intialize();
```

### ️🔐 Screen Guarding (Android Only)

#### Guard
```dart
   /// Guard Screen
  screenCaptureUtils.guard();
```
- This function will apply the FLAG_SECURE to the MainActivity of your app.

#### UnGuard
```dart
   /// Unguard Screen
  screenCaptureUtils.unGuard();
```
- This function will remove/clear the FLAG_SECURE from the MainActivity of your app.



## ✨ Contribution
 Lots of PR's would be needed to improve this plugin. So lots of suggestions and PRs are welcome.
