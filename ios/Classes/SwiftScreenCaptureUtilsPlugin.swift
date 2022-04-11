import Flutter
import UIKit
import Photos


public class SwiftScreenCaptureUtilsPlugin: NSObject, FlutterPlugin {
    
    
    final var TAG = "screen_capture_utils"
    let TAG_BLUR_VIEW = 2010292
    var blurView: UIVisualEffectView?
    var dartChannel: FlutterMethodChannel?
   
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        // Setup Channels
        let channel = FlutterMethodChannel(name: "screen_capture_utils", binaryMessenger: registrar.messenger())
        
        // Set up registrar
        let instance = SwiftScreenCaptureUtilsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 11.0, *) {
            
            DispatchQueue.main.async { [self] in
                switch call.method {
                case "initialize":
                    self.initialize(call:call, result: result)
                    
                case "guard":
                    
                    self.guardSceen(result: result)
                    
                case "unGuard":
                    
                    self.unGuardScreen(result: result)
                    
                default:
                    result(FlutterMethodNotImplemented)
                    return
                }
            }
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
        
        let flutterVC = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController
        
        dartChannel =  FlutterMethodChannel(name: "screen_capture_utils.dart", binaryMessenger: flutterVC as! FlutterBinaryMessenger)
        
        
        let value = UIScreen.main.isCaptured || UIScreen.screens.count > 1;
        dartChannel?.invokeMethod("onIOSScreenCaptured", arguments: value)

        result(true)
    }
    
    public func guardSceen(result: @escaping FlutterResult) {
        let window =  UIApplication.shared.windows.first!;
        
        if let view = window.rootViewController?.view.subviews.first(where: {$0.tag == TAG_BLUR_VIEW}){
            view.removeFromSuperview()
            blurView = nil
        }
        
        if blurView == nil{
            blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
            blurView?.effect = UIBlurEffect(style: .light)
            blurView?.tag = TAG_BLUR_VIEW
        }
        
        window.rootViewController?.view.insertSubview(blurView!, at: 0)
        result(true)
        
    }
    
    public func unGuardScreen(result: @escaping FlutterResult) {
        
        let window =  UIApplication.shared.windows.first!;
        
        if let view = window.rootViewController?.view.subviews.first(where: {$0.tag == TAG_BLUR_VIEW}){
            view.removeFromSuperview()
            blurView = nil
        }
        result(true)
    }
    
    
    @objc private func didScreenshot(_ notification: Notification) {
        dartChannel?.invokeMethod("onIOSScreenCaptured", arguments: true)
     
    }
    
    func listFilesFromDocumentsFolder() -> [String]?
    {
        let fileMngr = FileManager.default;
        
        // Full path to documents directory
        let docs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0].path
        
        // List all contents of directory and return as [String] OR nil if failed
        return try? fileMngr.contentsOfDirectory(atPath:docs)
    }
    
    
    @available(iOS 11.0, *)
    @objc private func didScreenRecording(_ notification: Notification) {
        // If a screen recording operation is pending then we close the application
        let value = UIScreen.main.isCaptured || UIScreen.screens.count > 1;
        dartChannel?.invokeMethod("onIOSScreenCaptured", arguments: value)
    }
    

}
