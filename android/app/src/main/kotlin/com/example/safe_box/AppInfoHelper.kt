
// working code without risk only permission
//package com.example.safe_box
//
//import android.content.Context
//import android.content.pm.PackageInfo
//import android.content.pm.PackageManager
//import android.graphics.Bitmap
//import android.graphics.drawable.BitmapDrawable
//import android.util.Base64
//import org.json.JSONArray
//import org.json.JSONObject
//import java.io.ByteArrayOutputStream
//
//class AppInfoHelper(private val context: Context) {
//
//    fun getInstalledAppsWithPermissions(): String {
//        val packageManager = context.packageManager
//        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
//
//        val appsArray = JSONArray()
//
//        for (app in installedApps) {
//
//            if ((app.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0) {
//                continue
//            }
//            val appObject = JSONObject()
//            appObject.put("appName", app.loadLabel(packageManager).toString())
//            appObject.put("packageName", app.packageName)
//            appObject.put("permissions", JSONArray(getAppPermissions(packageManager, app.packageName)))
//            appObject.put("icon", getAppIconBase64(packageManager, app.packageName)) // Adding the icon
//
//            appsArray.put(appObject)
//        }
//
//        return appsArray.toString()
//    }
//
//
//    private fun getAppPermissions(packageManager: PackageManager, packageName: String): List<String> {
//        return try {
//            val packageInfo: PackageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
//            packageInfo.requestedPermissions?.toList() ?: emptyList()
//        } catch (e: PackageManager.NameNotFoundException) {
//            emptyList()
//        }
//    }
//
//    private fun getAppIconBase64(packageManager: PackageManager, packageName: String): String {
//        return try {
//            val drawable = packageManager.getApplicationIcon(packageName)
//
//            val bitmap = if (drawable is BitmapDrawable) {
//                drawable.bitmap
//            } else {
//                // Convert AdaptiveIconDrawable to Bitmap
//                val bitmap = Bitmap.createBitmap(
//                    drawable.intrinsicWidth,
//                    drawable.intrinsicHeight,
//                    Bitmap.Config.ARGB_8888
//                )
//                val canvas = android.graphics.Canvas(bitmap)
//                drawable.setBounds(0, 0, canvas.width, canvas.height)
//                drawable.draw(canvas)
//                bitmap
//            }
//
//            val outputStream = ByteArrayOutputStream()
//            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
//            val byteArray = outputStream.toByteArray()
//            Base64.encodeToString(byteArray, Base64.NO_WRAP)
//        } catch (e: Exception) {
//            ""
//        }
//    }
//}


//1st itration of risk caculation
package com.example.safe_box

import android.app.AppOpsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.util.Base64
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream

class AppInfoHelper(private val context: Context) {

    fun getInstalledAppsWithPermissions(): String {
        val packageManager = context.packageManager
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        val appsArray = JSONArray()

        for (app in installedApps) {

            if ((app.flags and ApplicationInfo.FLAG_SYSTEM) != 0) {
                continue
            }

            val permissions = getAppPermissions(packageManager, app.packageName)
            val riskScore = calculateRiskScore(packageManager, app, permissions)

            val appObject = JSONObject()
            appObject.put("appName", app.loadLabel(packageManager).toString())
            appObject.put("packageName", app.packageName)
            appObject.put("permissions", JSONArray(permissions))
            appObject.put("riskScore", riskScore)
            appObject.put("icon", getAppIconBase64(packageManager, app.packageName))

            appsArray.put(appObject)
        }

        return appsArray.toString()
    }

    private fun getAppPermissions(packageManager: PackageManager, packageName: String): List<String> {
        return try {
            val packageInfo: PackageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
            packageInfo.requestedPermissions?.toList() ?: emptyList()
        } catch (e: PackageManager.NameNotFoundException) {
            emptyList()
        }
    }

    private fun getAppIconBase64(packageManager: PackageManager, packageName: String): String {
        return try {
            val drawable = packageManager.getApplicationIcon(packageName)
            val bitmap = if (drawable is BitmapDrawable) {
                drawable.bitmap
            } else {
                val bitmap = Bitmap.createBitmap(
                    drawable.intrinsicWidth,
                    drawable.intrinsicHeight,
                    Bitmap.Config.ARGB_8888
                )
                val canvas = android.graphics.Canvas(bitmap)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bitmap
            }

            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            val byteArray = outputStream.toByteArray()
            Base64.encodeToString(byteArray, Base64.NO_WRAP)
        } catch (e: Exception) {
            ""
        }
    }

    private fun calculateRiskScore(
        packageManager: PackageManager,
        appInfo: ApplicationInfo,
        permissions: List<String>
    ): Int {
        val dangerousPermissions = listOf(
            "android.permission.READ_CONTACTS",
            "android.permission.ACCESS_FINE_LOCATION",
            "android.permission.RECORD_AUDIO",
            "android.permission.CAMERA",
            "android.permission.SEND_SMS",
            "android.permission.READ_SMS",
            "android.permission.READ_PHONE_STATE",
            "android.permission.WRITE_EXTERNAL_STORAGE"
        )

        var score = 0

        // 1. Internet permission
        if (permissions.contains("android.permission.INTERNET")) {
            score += 15
        }

        // 2. Number of permissions
        score += permissions.size * 2

        // 3. Dangerous permissions count
        val dangerousCount = permissions.count { it in dangerousPermissions }
        score += dangerousCount * 10

        // 4. Obscure developer/package name
        if (!appInfo.packageName.startsWith("com.") && !appInfo.packageName.startsWith("org.")) {
            score += 10
        }

        // 5. System vs User app
        if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0) {
            score += 5
        }

        return score
    }
}


//
//package com.example.safe_box
//
//import android.app.AppOpsManager
//import android.content.Context
//import android.content.pm.ApplicationInfo
//import android.content.pm.PackageInfo
//import android.content.pm.PackageManager
//import android.graphics.Bitmap
//import android.graphics.drawable.BitmapDrawable
//import android.os.Build
//import android.util.Base64
//import android.util.Log
//import androidx.annotation.RequiresApi
//import org.json.JSONArray
//import org.json.JSONObject
//import java.io.ByteArrayOutputStream
//import java.util.concurrent.TimeUnit
//
//class AppInfoHelper(private val context: Context) {
//
//    fun getInstalledAppsWithPermissions(): String {
//        val packageManager = context.packageManager
//        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
//
//        val appsArray = JSONArray()
//
//        for (app in installedApps) {
//            if ((app.flags and ApplicationInfo.FLAG_SYSTEM) != 0) continue
//
//            val permissions = getAppPermissions(packageManager, app.packageName)
//            val usageHistory = getPermissionUsageStats(app.packageName)
//            val riskScore = calculateRiskScore(app, permissions, usageHistory)
//
//            val appObject = JSONObject().apply {
//                put("appName", app.loadLabel(packageManager).toString())
//                put("packageName", app.packageName)
//                put("permissions", JSONArray(permissions))
//                put("icon", getAppIconBase64(packageManager, app.packageName))
//                put("riskScore", riskScore)
//                put("permissionUsageHistory", JSONObject(usageHistory))
//            }
//
//            appsArray.put(appObject)
//        }
//
//        return appsArray.toString()
//    }
//
//    private fun getAppPermissions(packageManager: PackageManager, packageName: String): List<String> {
//        return try {
//            val packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
//            packageInfo.requestedPermissions?.toList() ?: emptyList()
//        } catch (e: PackageManager.NameNotFoundException) {
//            emptyList()
//        }
//    }
//
//    private fun getAppIconBase64(packageManager: PackageManager, packageName: String): String {
//        return try {
//            val drawable = packageManager.getApplicationIcon(packageName)
//            val bitmap = if (drawable is BitmapDrawable) {
//                drawable.bitmap
//            } else {
//                val bitmap = Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888)
//                val canvas = android.graphics.Canvas(bitmap)
//                drawable.setBounds(0, 0, canvas.width, canvas.height)
//                drawable.draw(canvas)
//                bitmap
//            }
//            val outputStream = ByteArrayOutputStream()
//            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
//            val byteArray = outputStream.toByteArray()
//            Base64.encodeToString(byteArray, Base64.NO_WRAP)
//        } catch (e: Exception) {
//            ""
//        }
//    }
//
//    private fun calculateRiskScore(
//        app: ApplicationInfo,
//        permissions: List<String>,
//        usageHistory: Map<String, Long>
//    ): Int {
//        var score = 0.0
//
//        val hasInternet = permissions.any { it.contains("INTERNET") }
//        val dangerousCount = permissions.count { isDangerousPermission(it) }
//        val obscureDeveloper = app.packageName.split(".").size <= 2
//        val unusedPermissions = permissions.count { !usageHistory.containsKey(it) }
//        val totalPermissions = permissions.size
//
//        if (hasInternet) score += 15.0
//        score += (dangerousCount * 2.5)
//        if (obscureDeveloper) score += 15.0
//        score += (unusedPermissions * 1.5)
//        score += (totalPermissions * 1.0)
//
//        val avgUsage = if (usageHistory.isNotEmpty()) usageHistory.values.average() else 0.0
//        if (avgUsage > TimeUnit.HOURS.toMillis(1)) score += 10.0
//
//        return score.coerceIn(0.0, 1000.0).toInt()
//    }
//
//    private fun isDangerousPermission(permission: String): Boolean {
//        val dangerousPermissions = listOf(
//            "READ_CONTACTS", "WRITE_CONTACTS", "READ_SMS", "SEND_SMS", "RECEIVE_SMS",
//            "ACCESS_FINE_LOCATION", "ACCESS_COARSE_LOCATION", "READ_EXTERNAL_STORAGE",
//            "WRITE_EXTERNAL_STORAGE", "RECORD_AUDIO", "CAMERA"
//        )
//        return dangerousPermissions.any { permission.contains(it) }
//    }
//
//    private fun getPermissionUsageStats(packageName: String): Map<String, Long> {
//        val usageMap = mutableMapOf<String, Long>()
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//            try {
//                val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
//                val packageUid = context.packageManager.getApplicationInfo(packageName, 0).uid
//
//                val opsList = listOf(
//                    AppOpsManager.OPSTR_FINE_LOCATION,
//                    AppOpsManager.OPSTR_COARSE_LOCATION,
//                    AppOpsManager.OPSTR_READ_SMS,
//                    AppOpsManager.OPSTR_CAMERA,
//                    AppOpsManager.OPSTR_RECORD_AUDIO,
//                    AppOpsManager.OPSTR_READ_CONTACTS
//                )
//
//                for (op in opsList) {
//                    val opEntry = appOps.unsafeCheckOpNoThrow(op, packageUid, packageName)
//                    if (opEntry == AppOpsManager.MODE_ALLOWED) {
//                        val now = System.currentTimeMillis()
//                        val usage = now - TimeUnit.MINUTES.toMillis((1..180).random().toLong())
//                        usageMap[op] = usage
//                    }
//                }
//            } catch (e: Exception) {
//                Log.e("PermissionUsage", "Error reading usage: ${e.localizedMessage}")
//            }
//        }
//
//        return usageMap
//    }
//}
//
//
//
//
