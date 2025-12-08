package com.example.project_uas

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.app.usage.UsageStatsManager
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.project_uas/app_blocking"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setBlockedApps" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    AppBlockingService.updateBlockedPackages(packages.toSet())
                    result.success(true)
                }
                "setBlockingEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    AppBlockingService.setBlockingEnabled(enabled)
                    result.success(true)
                }
                "isAccessibilityServiceEnabled" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "openAccessibilitySettings" -> {
                    openAccessibilitySettings()
                    result.success(true)
                }
                "getInstalledApps" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        result.success(getInstalledApps())
                    } else {
                        result.error("UNSUPPORTED", "Android version not supported", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun isAccessibilityServiceEnabled(): Boolean {
        val accessibilityManager = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        val enabledServices = accessibilityManager.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
        
        for (service in enabledServices) {
            if (service.resolveInfo.serviceInfo.packageName == packageName) {
                return true
            }
        }
        return false
    }
    
    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }
    
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getInstalledApps(): List<Map<String, String>> {
        val pm = packageManager
        val apps = pm.getInstalledPackages(PackageManager.GET_META_DATA)
        val appList = mutableListOf<Map<String, String>>()
        
        for (packageInfo in apps) {
            // Skip system apps yang tidak penting
            val appInfo = packageInfo.applicationInfo ?: continue
            if (appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM != 0) {
                continue
            }
            
            val appName = pm.getApplicationLabel(appInfo).toString()
            val packageName = packageInfo.packageName
            
            appList.add(mapOf(
                "name" to appName,
                "package" to packageName
            ))
        }
        
        return appList.sortedBy { it["name"] }
    }
}
