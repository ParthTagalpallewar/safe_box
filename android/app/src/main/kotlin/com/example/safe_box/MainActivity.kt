

package com.example.safe_box

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app_info_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInstalledApps") {
                val appInfoHelper = AppInfoHelper(this)
                val appsData = appInfoHelper.getInstalledAppsWithPermissions()
                result.success(appsData)
            } else {
                result.notImplemented()
            }
        }
    }
}


