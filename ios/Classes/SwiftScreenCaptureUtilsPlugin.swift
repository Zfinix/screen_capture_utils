import Flutter
import UIKit

public class SwiftScreenCaptureUtilsPlugin: NSObject, FlutterPlugin {
    final var TAG = "screen_capture_utils"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
         // Setup Channels
        let channel = FlutterMethodChannel(name: "screen_capture_utils", binaryMessenger: registrar.messenger())
       
        // Set up registrar
        let instance = SwiftScreenCaptureUtilsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if #available(iOS 11.0, *) {
            initialize(call: call, result: result)
        } else {
            result(FlutterError.init(code: TAG, message:  "initialize error", details: "not supported pre iOS 11.0"))
        }
    }
    
    @available(iOS 11.0, *)
    public func initialize(call: FlutterMethodCall, result: @escaping FlutterResult){
        
      
        
        //Define a listener to handle the case when a screen recording is launched
        //for example using the iPhone built-in feature
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didScreenRecording(_:)),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
        
        //Define a listener to handle the case when a screenshot is performed
        //Unfortunately screenshot cannot be prevented but just detected...
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didScreenshot(_:)),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil)
    }
    
    
    @objc private func didScreenshot(_ notification: Notification) {
        dartChannel().invokeMethod("onScreenCaptured", arguments: nil)
    }
    
   
    @available(iOS 11.0, *)
    @objc private func didScreenRecording(_ notification: Notification) {
        // If a screen recording operation is pending then we close the application
      
        if UIScreen.main.isCaptured {
            dartChannel().invokeMethod("onScreenCaptured", arguments: nil)
        }
    }
    
  
    
}

fileprivate func dartChannel() -> FlutterMethodChannel {
    let flutterVC = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController
    return FlutterMethodChannel(name: "screen_capture_utils.dart", binaryMessenger: flutterVC as! FlutterBinaryMessenger)
}
