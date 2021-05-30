package tech.chizi.screen_capture_utils


import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import android.view.Window
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import com.akexorcist.screenshotdetection.ScreenshotDetectionDelegate
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import java.io.IOException
import java.lang.Error


internal class MethodCallHandlerImpl(context: Context, activity: Activity?, channel:MethodChannel?) : MethodCallHandler, PluginRegistry.RequestPermissionsResultListener, ScreenshotDetectionDelegate.ScreenshotDetectionListener {

    private val tag: String = "screen_capture"
    private var context: Context?
    private var channel: MethodChannel?
    private var activity: Activity?
    private var kMethodCall: MethodCall? = null
    private var kResult: MethodChannel.Result? = null
    private var screenshotDetectionDelegate: ScreenshotDetectionDelegate? = null
    private val REQUEST_CODE_READ_EXTERNAL_STORAGE_PERMISSION = 3009


    init {
        this.activity = activity
        this.context = context
        this.channel = channel
    }

    fun setActivity(act: Activity?) {
        this.activity = act
    }

   override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
     when (call.method) {
        "initialize" -> {
           try {
               this.screenshotDetectionDelegate = ScreenshotDetectionDelegate(activity!!, this)
               screenshotDetectionDelegate?.startScreenshotDetection()
               checkReadExternalStoragePermission(result)
               result.success(true)
           } catch (e: IOException){
               result.error(tag, e.message, e.localizedMessage)
           }
        }
        
        "guard" -> {
            applyFlagSecure(true)
            result.success(true)
        }

        "unGuard" -> {
            activity!!.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            result.success(true)
        }

        else -> {
            result.notImplemented()
        }
     }
  } 

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        when (requestCode) {
            REQUEST_CODE_READ_EXTERNAL_STORAGE_PERMISSION -> {
                if (grantResults.getOrNull(0) == PackageManager.PERMISSION_DENIED) {
                    showReadExternalStoragePermissionDeniedMessage()
                    return false
                } else {
                    kResult?.success(true)
                }
            }
            else -> {
                kResult?.error(tag, "Unable to get permission", null)
            }
        }
        return false
    }

    private fun checkReadExternalStoragePermission(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(activity!!, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            requestReadExternalStoragePermission()
            screenshotDetectionDelegate?.startScreenshotDetection()
            result.success(true)
        }
    }

    private fun requestReadExternalStoragePermission() {
        ActivityCompat.requestPermissions(activity!!, arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE), REQUEST_CODE_READ_EXTERNAL_STORAGE_PERMISSION)
    }

    private fun showReadExternalStoragePermissionDeniedMessage() {
        kResult?.error(tag, "Read external storage permission has denied", null)
    }

    override fun onScreenCaptured(path: String) {
        val args: HashMap<String, Any> = HashMap()
        args["path"] = path
        Log.d(tag, path)
        channel!!.invokeMethod("onScreenCaptured", args)
    }

    override fun onScreenCapturedWithDeniedPermission() {
        Log.d(tag, "onScreenCapturedWithDeniedPermission")
       channel!!.invokeMethod("onScreenCapturedWithDeniedPermission", null)
    }

    fun applyFlagSecure(flagSecure: Boolean) {
        val window: Window = activity!!.window
        val wm: WindowManager = activity!!.windowManager

        // is change needed?
        val flags: Int = window.attributes.flags
        if (flagSecure && flags and WindowManager.LayoutParams.FLAG_SECURE != 0) {
            // already set, change is not needed.
            return
        } else if (!flagSecure && flags and WindowManager.LayoutParams.FLAG_SECURE == 0) {
            // already cleared, change is not needed.
            return
        }

        // apply (or clear) the FLAG_SECURE flag to/from Activity this Fragment is attached to.
        var flagsChanged: Boolean
        flagsChanged = if (flagSecure) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            true
        } else {
            // Okay, it is safe to clear FLAG_SECURE flag from Window flags.
            // Activity is (probably) not showing any secure content.
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            true
        }

        // Re-apply (re-draw) Window's DecorView so the change to the Window flags will be in place immediately.
        if (flagsChanged && ViewCompat.isAttachedToWindow(window.decorView)) {
            // FIXME Removing the View and attaching it back makes visible re-draw on Android 4.x, 5+ is good.
            wm.removeViewImmediate(window.decorView)
            wm.addView(window.decorView, window.attributes)
        }
    }


}
