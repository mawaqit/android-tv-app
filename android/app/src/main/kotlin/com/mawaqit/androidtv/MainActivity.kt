package com.mawaqit.androidtv

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
import java.io.IOException
import android.app.KeyguardManager
import android.os.AsyncTask
import android.util.Log
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import  android.net.ConnectivityManager
import java.util.concurrent.Executors
import android.os.Looper
import android.os.Handler
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.app.AlarmManager

class MainActivity : FlutterActivity() {
  private lateinit var mAdminComponentName: ComponentName
  private lateinit var mDevicePolicyManager: DevicePolicyManager

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nativeMethodsChannel")
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

          "checkRoot" -> result.success(checkRoot())
          "connectToNetworkWPA" -> connectToNetworkWPA(call, result)
          "addLocationPermission" -> addLocationPermission(call, result)
          "grantFineLocationPermission" -> grantFineLocationPermission(call, result)
          "grantOverlayPermission" -> grantOverlayPermission(call, result)
          "sendDownArrowEvent" -> sendDownArrowEvent(call, result)
          "sendTabKeyEvent" -> sendTabKeyEvent(call, result)
          "clearAppData" -> {
            val isSuccess = clearDataRestart()
            result.success(isSuccess)
          }
          "enableBatteryOptimization" -> enableBatteryOptimization(call, result)
          "DisableDozeMode" -> disableDozeMode(call, result)
          "grantOnvoOverlayPermission" -> {
            val isSuccess = grantOnvoOverlayPermission()
            result.success(isSuccess)
          }
          "requestExactAlarmPermission" -> {
            if (VERSION.SDK_INT >= VERSION_CODES.S) {
              val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.fromParts("package", "com.mawaqit.androidtv", null)
              }
              startActivity(intent)
              result.success(true)
            } else {
              result.success(true)
            }
          }
          "checkExactAlarmPermission" -> {
              val canSchedule = if (VERSION.SDK_INT >= VERSION_CODES.S) {
                val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                alarmManager.canScheduleExactAlarms()
              } else {
                true
              }
              result.success(canSchedule)
            }
          "installApk" -> {
            val filePath = call.argument<String>("filePath")
            if (filePath != null) {
              AsyncTask.execute {
                try {
                  // Check if file exists
                  val file = java.io.File(filePath)
                  if (!file.exists()) {
                    Log.e("APK_INSTALL", "APK file not found at path: $filePath")
                    result.error("FILE_NOT_FOUND", "APK file not found", null)
                    return@execute
                  }
                  // Check if device is rooted
                  if (!checkRoot()) {
                    Log.e("APK_INSTALL", "Device is not rooted")
                    result.error("NOT_ROOTED", "Device is not rooted", null)
                    return@execute
                  }
                  val commands = listOf("pm install -r -d $filePath")
                  executeCommand(commands, result)
                } catch (e: Exception) {
                  Log.e("APK_INSTALL", "Failed to install APK", e)
                  result.error("INSTALL_FAILED", e.message, null)
                }
              }
            } else {
              result.error("INVALID_PATH", "File path is null", null)
            }
          }

          else -> result.notImplemented()
        }
      }
  }

  private fun checkRoot(): Boolean {
    return try {
      val p = Runtime.getRuntime().exec("su")
      val os = DataOutputStream(p.outputStream)
      os.writeBytes("echo \"Do I have root?\" >/data/LandeRootCheck.txt\n")
      os.writeBytes("exit\n")
      os.flush()
      p.waitFor()
      p.exitValue() == 0
    } catch (e: Exception) {
      false
    }
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val REQUEST_OVERLAY_PERMISSIONS = 100
    if (checkRoot() && !Settings.canDrawOverlays(applicationContext)) {
      try {
        val command = "appops set com.mawaqit.androidtv SYSTEM_ALERT_WINDOW allow"
        val process = Runtime.getRuntime().exec(arrayOf("su", "-c", command))
        val outputStream = DataOutputStream(process.outputStream)
        outputStream.writeBytes(command + "\n")
        outputStream.flush()
        outputStream.close()
        process.waitFor()
      } catch (e: Exception) {
        e.printStackTrace()
      }
    }
  }

  private fun grantOnvoOverlayPermission(): Boolean {
    return try {
      val processBuilder = ProcessBuilder()
      val command = "sh -c appops set com.mawaqit.androidtv SYSTEM_ALERT_WINDOW allow"

      processBuilder.command(
        "sh", "-c", """
            appops set com.mawaqit.androidtv SYSTEM_ALERT_WINDOW allow
        """.trimIndent()
      )

      val process = processBuilder.start()
      val exitCode = process.waitFor()

      exitCode == 0
    } catch (e: Exception) {
      e.printStackTrace()
      false
    }
  }

  private fun setDeviceTimezone(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
      try {
        val timezone = call.argument<String>("timezone")
        executeCommand(listOf("service call alarm 3 s16 $timezone"), result)
      } catch (e: Exception) {
        handleCommandException(e, result)
      }
    }
  }

  private fun addLocationPermission(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
      try {
        executeCommand(listOf("settings put secure location_mode 3"), result)
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
        val security = if (password.isNullOrEmpty()) "open" else "wpa2"

        Log.i("SU_COMMAND", "Wifi Command output: cmd wifi connect-network $ssid $security $password")

        executeCommand(listOf("cmd wifi connect-network $ssid $security $password"), result)

      } catch (e: Exception) {
        handleCommandException(e, result)
      }
    }
  }

  fun connectToNetworkWPA(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
      try {
        val networkSSID = call.argument<String>("ssid")
        val password = call.argument<String>("password")
        val conf = WifiConfiguration().apply {
          SSID = "\"$networkSSID\""
          status = WifiConfiguration.Status.ENABLED
          allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP)
          allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP)
          allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP)
          allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP)
          if (password.isNullOrEmpty()) {
            allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE)
          } else {
            preSharedKey = "\"$password\""
            allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK)
          }
        }

        Log.d("connectToNetworkWPA", "Connecting to SSID: ${conf.SSID}")

        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val networkId = wifiManager.addNetwork(conf)
        wifiManager.disconnect()
        wifiManager.enableNetwork(networkId, true)
        wifiManager.reconnect()

        // Wait for the connection to be established
        var connectionAttempts = 0
        while (wifiManager.getConnectionInfo().networkId == -1 && connectionAttempts < 3) {
          Thread.sleep(500)
          connectionAttempts++
        }

        val wifiInfo = wifiManager.getConnectionInfo()
        if (wifiInfo.networkId != -1) {
          Log.d("connectToNetworkWPA", "Connected to network:")
          result.success(true)
        } else {
          Log.e("connectToNetworkWPA", "Failed to connect to network")
          result.success(false)
        }
      } catch (ex: Exception) {
        Log.e("connectToNetworkWPA", "Error connecting to network", ex)
        result.error("exception", ex.message, ex)
      }
    }
  }

  private fun clearDataRestart(): Boolean {
    return try {
      val processBuilder = ProcessBuilder()
      processBuilder.command(
        "sh", "-c", """
                pm clear com.mawaqit.androidtv
            """.trimIndent()
      )
      val process = processBuilder.start()
      val exitCode = process.waitFor()
      exitCode == 0
    } catch (e: Exception) {
      e.printStackTrace()
      false
    }
  }

  private fun enableBatteryOptimization(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
      try {
        val commands = listOf(
          "dumpsys deviceidle whitelist +com.mawaqit.androidtv",

          )
        executeCommand(commands, result) // Lock the device
      } catch (e: Exception) {
        handleCommandException(e, result)
      }
    }
  }
  private fun disableDozeMode(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
      try {
        val commands = listOf(
          "dumpsys deviceidle disable",
          )
        executeCommand(commands, result) // Lock the device
      } catch (e: Exception) {
        handleCommandException(e, result)
      }
    }
  }
  private fun grantFineLocationPermission(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
      try {
        val commands = listOf(
          "pm grant com.mawaqit.androidtv android.permission.ACCESS_FINE_LOCATION",

          )
        executeCommand(commands, result) // Lock the device
      } catch (e: Exception) {
        handleCommandException(e, result)
      }
    }
  }

  private fun grantOverlayPermission(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
      try {
        val commands = listOf(
          "appops set com.mawaqit.androidtv SYSTEM_ALERT_WINDOW allow",

          )
        executeCommand(commands, result) // Lock the device
      } catch (e: Exception) {
        handleCommandException(e, result)
      }
    }
  }


  private fun sendDownArrowEvent(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
      try {
        val commands = listOf(
          "input keyevent 20"
        )
        executeCommand(commands, result)
      } catch (e: Exception) {
        handleCommandException(e, result)
      }
    }
  }

  private fun sendTabKeyEvent(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
      try {
        val commands = listOf(
          "input keyevent 61"
        )
        executeCommand(commands, result)
      } catch (e: Exception) {
        handleCommandException(e, result)
      }
    }
  }


  private fun executeCommand(commands: List<String>, result: MethodChannel.Result) {
    try {
      Log.d("SU_COMMAND", "Executing commands: ${commands.joinToString(separator = " && ")}")

      val suProcess = Runtime.getRuntime().exec("su")
      val os = DataOutputStream(suProcess.outputStream)

      val command = commands.joinToString(separator = " && ") + "\n"
      Log.d("SU_COMMAND", "Writing command to DataOutputStream: $command")
      os.writeBytes(command)
      os.flush()
      os.close()

      val output = BufferedReader(InputStreamReader(suProcess.inputStream)).readText()
      val error = BufferedReader(InputStreamReader(suProcess.errorStream)).readText()

      Log.i("SU_COMMAND", "Command output: $output")
      Log.e("SU_COMMAND", "Command error: $error")

      val exitCode = suProcess.waitFor()
      Log.d("SU_COMMAND", "Exit code: $exitCode")

      if (exitCode != 0 || output.contains("Connection failed")) {
        Log.e("SU_COMMAND", "Command failed with exit code $exitCode.")
        result.success(false)
      } else {
        Log.i("SU_COMMAND", "Command executed successfully.")
        result.success(true)
      }
    } catch (e: Exception) {
      Log.e("SU_COMMAND", "Exception occurred: ${e.message}")
      handleCommandException(e, result)
    }
  }


  private fun handleCommandException(e: Exception, result: MethodChannel.Result) {
    result.error("Exception", "An exception occurred: $e", null)
  }
}
