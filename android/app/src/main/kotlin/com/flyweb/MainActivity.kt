package com.mawaqit.androidtv

import android.os.AsyncTask
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.DataOutputStream
import java.io.InputStreamReader
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import android.content.Intent
import android.net.Uri
import java.io.File
import android.content.Context
import android.content.ComponentName
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.app.admin.DevicePolicyManager

class MainActivity : FlutterActivity() {
private lateinit var mAdminComponentName: ComponentName
  private lateinit var mDevicePolicyManager: DevicePolicyManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nativeFunctionsChannel")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setDeviceTimezone" -> setDeviceTimezone(call, result)
                    "connectToWifi" -> connectToWifi(call, result)
                    "isPackageInstalled" -> {
                            val packageName = call.argument<String>("packageName")
                            if (packageName != null) {
                                val isInstalled = isPackageInstalled(packageName)
                                result.success(isInstalled)
                            } else {
                                result.error("INVALID_ARGUMENT", "Package name is null", null)
                            }
                        }  
                    "startKioskMode"->manageKioskMode(true)
                    "stopKioskMode"->manageKioskMode(false)           
                             else -> result.notImplemented()
                }
            }
    }
      private fun manageKioskMode(enable: Boolean) {
    if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
        mDevicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        mAdminComponentName = MyDeviceAdminReceiver.getComponentName(this)
        mDevicePolicyManager.setLockTaskPackages(mAdminComponentName, arrayOf(packageName))
        if(enable) {
          this.startLockTask()
        } else {
          this.stopLockTask()
        }
      return
    }
  }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        var REQUEST_OVERLAY_PERMISSIONS = 100
        if (isRootAvailable() && !Settings.canDrawOverlays(getApplicationContext())) {
            val myIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            val uri: Uri = Uri.fromParts("package", getPackageName(), null)
            myIntent.setData(uri)
            startActivityForResult(myIntent, REQUEST_OVERLAY_PERMISSIONS)
            return
        }
    }

    private fun isRootAvailable(): Boolean {
        System.getenv("PATH")?.split(":")?.forEach { pathDir ->
            if (File(pathDir, "su").exists()) {
                return true
            }
        }
        return false
    }
  
    private fun setDeviceTimezone(call: MethodCall, result: MethodChannel.Result) {
        AsyncTask.execute {
            try {
                val timezone = call.argument<String>("timezone")
                executeCommand("service call alarm 3 s16 $timezone", result)
            } catch (e: Exception) {
                handleCommandException(e, result)
            }
        }
    }

    private fun isPackageInstalled(packageName: String?): Boolean {
        val packageManager = applicationContext.packageManager
        return try {
            packageManager.getPackageInfo(packageName!!, PackageManager.GET_ACTIVITIES)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
    private fun connectToWifi(call: MethodCall, result: MethodChannel.Result) {
        AsyncTask.execute {
            try {
                val ssid = call.argument<String>("ssid")
                val password = call.argument<String>("password")
                var security = call.argument<String>("security")

                if (security?.contains("ESS", ignoreCase = true) == true) {
                    security = "open"
                } else if (security?.contains("wpa2", ignoreCase = true) == true) {
                    security = "wpa2"
                } else if (security?.contains("wpa3", ignoreCase = true) == true) {
                    security = "wpa3"
                }

                executeCommand("cmd wifi connect-network $ssid $security $password", result)

            } catch (e: Exception) {
                handleCommandException(e, result)
            }
        }
    }

    private fun executeCommand(command: String, result: MethodChannel.Result) {
        try {
            val suProcess = Runtime.getRuntime().exec("su")
            val os = DataOutputStream(suProcess.outputStream)

            os.writeBytes(command + "\n")
            os.flush()
            os.close()

            val output = BufferedReader(InputStreamReader(suProcess.inputStream)).readText()
            val error = BufferedReader(InputStreamReader(suProcess.errorStream)).readText()

            Log.i("SU_COMMAND", "Command output: $output")
            Log.e("SU_COMMAND", "Command error: $error")

            val exitCode = suProcess.waitFor()

            if (exitCode != 0) {
                Log.e("SU_COMMAND", "Command failed with exit code $exitCode.")
                result.error("CMD_ERROR", "Command failed", null)
            } else {
                Log.i("SU_COMMAND", "Command executed successfully.")
                result.success("Command executed successfully.")
            }
        } catch (e: Exception) {
            handleCommandException(e, result)
        }
    }

    private fun handleCommandException(e: Exception, result: MethodChannel.Result) {
        Log.e("SU_COMMAND", "Exception while executing command: ${e.message}")
        result.error("CMD_ERROR", "Exception while executing command", null)
    }
}
