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
import 	android.net.ConnectivityManager

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
                    "toggleBoxScreenOff" -> toggleBoxScreenOff(call, result)
                    "toggleBoxScreenOn" -> toggleBoxScreenOn(call, result)
                    "connectToNetworkWPA" -> connectToNetworkWPA(call, result)
                    "addLocationPermission" -> addLocationPermission(call, result)
                    "grantFineLocationPermission" -> grantFineLocationPermission(call, result)
                    "sendDownArrowEvent" -> sendDownArrowEvent(call, result)
                    "sendTabKeyEvent" -> sendTabKeyEvent(call, result)
                    "clearAppData" -> {
                        val isSuccess = clearDataRestart()
                        result.success(isSuccess)
                    }
"installApk" -> {
    val filePath = call.argument<String>("filePath")
    if (filePath == null) {
        Log.e("APK_INSTALL", "File path is null")
        result.error("INVALID_PATH", "File path is null", null)
    } else {
        val filePath = call.argument<String>("filePath")
if (filePath == null) {
    Log.e("APK_INSTALL", "File path is null")
    result.error("INVALID_PATH", "File path is null", null)
} else {
    AsyncTask.execute {
        try {
            Log.d("APK_INSTALL", "Starting installation process...")
            Log.d("APK_INSTALL", "File path: $filePath")

            val file = java.io.File(filePath)
            if (!file.exists()) {
                Log.e("APK_INSTALL", "APK file not found at path: $filePath")
                result.error("FILE_NOT_FOUND", "APK file not found", null)
                return@execute
            }

            if (!checkRoot()) {
                Log.e("APK_INSTALL", "Device is not rooted")
                result.error("NOT_ROOTED", "Device is not rooted", null)
                return@execute
            }

            val packageName = "com.mawaqit.androidtv"

            // Modified script to wait for package installation to complete
            val scriptContent = """
                #!/system/bin/sh
                # Wait for package to be fully installed and ready
                while ! pm path $packageName >/dev/null 2>&1; do
                    sleep 1
                done
                # Additional wait for system to settle
                sleep 3
                # Launch the app
                am start -n $packageName/$packageName.MainActivity
            """.trimIndent()

            val scriptFile = File(context.cacheDir, "launch_script.sh")
            scriptFile.writeText(scriptContent)
            scriptFile.setExecutable(true)

            // Launch the script first, then install
            executeCommands(listOf(
                "nohup sh ${scriptFile.absolutePath} >/dev/null 2>&1 &",
                "pm install -r -d $filePath"
            ))

            result.success(true)

        } catch (e: Exception) {
            Log.e("APK_INSTALL", "Failed to install APK", e)
            try {
                result.error("INSTALL_FAILED", e.message, null)
            } catch (e: IllegalStateException) {
                Log.e("APK_INSTALL", "Result already submitted", e)
            }
        }
    }
}
    }
}
                    else -> result.notImplemented()
                }
            }
    }
private fun executeCommands(commands: List<String>): Boolean {
    return try {
        val process = Runtime.getRuntime().exec("su")
        val outputStream = DataOutputStream(process.outputStream)
        
        for (command in commands) {
            Log.d("SU_COMMAND", "Executing command: $command")
            outputStream.writeBytes("$command\n")
        }
        
        outputStream.writeBytes("exit\n")
        outputStream.flush()
        outputStream.close()
        
        val exitCode = process.waitFor()
        exitCode == 0
    } catch (e: Exception) {
        Log.e("SU_COMMAND", "Error executing command", e)
        false
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
            processBuilder.command("sh", "-c", """
                pm clear com.mawaqit.androidtv
            """.trimIndent())
            val process = processBuilder.start()
            val exitCode = process.waitFor()
            exitCode == 0
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun toggleBoxScreenOff(call: MethodCall, result: MethodChannel.Result) {
        AsyncTask.execute {
            try {
                val commands = listOf(
                    "mount -o rw,remount /",
                    "cd /sys/class/hdmi/hdmi/attr",
                    "echo 0 > phy_power"
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

    private fun toggleBoxScreenOn(call: MethodCall, result: MethodChannel.Result) {
        AsyncTask.execute {
            try {
                val commands = listOf(
                    "mount -o rw,remount /",
                    "cd /sys/class/hdmi/hdmi/attr",
                    "echo 1 > phy_power",
                    "am start -W -n com.mawaqit.androidtv/.MainActivity"
                )
                executeCommand(commands, result)
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

            if (exitCode != 0 || output.contains("Connection failed"))  {
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

