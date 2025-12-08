package com.example.project_uas

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.util.Log

/**
 * Accessibility Service untuk mendeteksi aplikasi yang dibuka
 * dan memblokir aplikasi yang ada di daftar block
 */
class AppBlockingService : AccessibilityService() {
    
    companion object {
        private const val TAG = "AppBlockingService"
        private var blockedPackages: Set<String> = emptySet()
        private var isBlockingEnabled: Boolean = false
        
        fun updateBlockedPackages(packages: Set<String>) {
            blockedPackages = packages
            Log.d(TAG, "Updated blocked packages: $packages")
        }
        
        fun setBlockingEnabled(enabled: Boolean) {
            isBlockingEnabled = enabled
            Log.d(TAG, "Blocking enabled: $enabled")
        }
    }
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "AppBlockingService connected")
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isBlockingEnabled || blockedPackages.isEmpty()) {
            return
        }
        
        event?.let {
            // Deteksi berbagai jenis event untuk memastikan aplikasi terdeteksi
            if (it.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED ||
                it.eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) {
                val packageName = it.packageName?.toString()
                if (packageName != null && blockedPackages.contains(packageName)) {
                    Log.d(TAG, "Blocked app detected: $packageName")
                    blockApp(packageName)
                }
            }
        }
    }
    
    private fun blockApp(packageName: String) {
        try {
            // Force close aplikasi menggunakan performGlobalAction
            performGlobalAction(GLOBAL_ACTION_BACK)
            Thread.sleep(100) // Delay kecil untuk memastikan action dieksekusi
            
            // Kembalikan ke home screen
            performGlobalAction(GLOBAL_ACTION_HOME)
            
            // Tampilkan overlay blocking setelah delay
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                try {
                    val overlayIntent = Intent(this, BlockingOverlayActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                        putExtra("blocked_package", packageName)
                    }
                    startActivity(overlayIntent)
                } catch (e: Exception) {
                    Log.e(TAG, "Error showing overlay: ${e.message}", e)
                }
            }, 300)
        } catch (e: Exception) {
            Log.e(TAG, "Error blocking app: ${e.message}", e)
            // Fallback: coba dengan intent biasa
            try {
                val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                startActivity(homeIntent)
            } catch (e2: Exception) {
                Log.e(TAG, "Error with fallback: ${e2.message}", e2)
            }
        }
    }
    
    override fun onInterrupt() {
        Log.d(TAG, "AppBlockingService interrupted")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "AppBlockingService destroyed")
    }
}

