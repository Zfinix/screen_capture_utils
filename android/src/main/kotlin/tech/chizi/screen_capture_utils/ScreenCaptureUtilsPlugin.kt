package tech.chizi.screen_capture_utils

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

/** ScreenCaptureUtilsPlugin */
class ScreenCaptureUtilsPlugin: FlutterPlugin, ActivityAware {
  
  private lateinit var channel : MethodChannel
  private lateinit var dartChannel : MethodChannel
  private lateinit var handler : MethodCallHandlerImpl


  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    setupChannel(flutterPluginBinding)
  }

  private fun setupChannel(pluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(pluginBinding.binaryMessenger, "screen_capture_utils")
    dartChannel = MethodChannel(pluginBinding.binaryMessenger, "screen_capture_utils.dart")
    handler = MethodCallHandlerImpl(pluginBinding.applicationContext, null, dartChannel)
    channel.setMethodCallHandler(handler)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

   override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    handler.setActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    handler.setActivity(null)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    
  }

}
