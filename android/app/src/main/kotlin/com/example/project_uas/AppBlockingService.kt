package com.example.project_uas

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import android.content.pm.PackageManager

/**
 * Accessibility Service untuk mendeteksi aplikasi yang dibuka
 * dan memblokir aplikasi yang ada di daftar block
 * 
 * DIPERKUAT: Deteksi lebih cepat dan agresif untuk memastikan aplikasi benar-benar terblokir
 */
class AppBlockingService : AccessibilityService() {
    
    companion object {
        private const val TAG = "AppBlockingService"
        private var blockedPackages: Set<String> = emptySet()
        private var isBlockingEnabled: Boolean = false
        private var lastBlockedPackage: String? = null
        private var lastBlockTime: Long = 0
        
        fun updateBlockedPackages(packages: Set<String>) {
            blockedPackages = packages
            Log.d(TAG, "========== UPDATED BLOCKED PACKAGES ==========")
            Log.d(TAG, "Packages: $packages")
            Log.d(TAG, "Total blocked apps: ${packages.size}")
            Log.d(TAG, "Blocking enabled: $isBlockingEnabled")
        }
        
        fun setBlockingEnabled(enabled: Boolean) {
            isBlockingEnabled = enabled
            Log.d(TAG, "========== BLOCKING ENABLED: $enabled ==========")
            Log.d(TAG, "Blocked packages: $blockedPackages")
            Log.d(TAG, "Total blocked apps: ${blockedPackages.size}")
            if (enabled && blockedPackages.isNotEmpty()) {
                Log.d(TAG, "✅ Monitoring ACTIVE for: $blockedPackages")
            } else if (enabled) {
                Log.w(TAG, "⚠️ Blocking enabled but NO apps blocked!")
            } else {
                Log.d(TAG, "❌ Blocking DISABLED")
            }
        }
    }
    
    private val handler = Handler(Looper.getMainLooper())
    private val monitoringRunnable = object : Runnable {
        override fun run() {
            if (isBlockingEnabled && blockedPackages.isNotEmpty()) {
                checkCurrentApp()
            }
            // Monitor setiap 50ms untuk deteksi SANGAT CEPAT
            handler.postDelayed(this, 50)
        }
    }
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "========== AppBlockingService CONNECTED ==========")
        Log.d(TAG, "Blocking enabled: $isBlockingEnabled")
        Log.d(TAG, "Blocked packages: $blockedPackages")
        Log.d(TAG, "Total blocked apps: ${blockedPackages.size}")
        
        // Mulai monitoring berkelanjutan
        handler.post(monitoringRunnable)
        Log.d(TAG, "Monitoring started")
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isBlockingEnabled) {
            return
        }
        
        if (blockedPackages.isEmpty()) {
            return
        }
        
        event?.let {
            // Deteksi berbagai jenis event untuk memastikan aplikasi terdeteksi
            val eventTypes = listOf(
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
                AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED,
                AccessibilityEvent.TYPE_VIEW_FOCUSED,
                AccessibilityEvent.TYPE_VIEW_CLICKED
            )
            
            if (eventTypes.contains(it.eventType)) {
                val packageName = it.packageName?.toString()
                if (packageName != null) {
                    if (blockedPackages.contains(packageName)) {
                        // Cegah spam blocking untuk package yang sama dalam waktu singkat (500ms)
                        val currentTime = System.currentTimeMillis()
                        if (packageName != lastBlockedPackage || currentTime - lastBlockTime > 500) {
                            Log.w(TAG, "🚫 BLOCKED APP DETECTED via event: $packageName (eventType: ${it.eventType})")
                            blockApp(packageName)
                            lastBlockedPackage = packageName
                            lastBlockTime = currentTime
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Cek aplikasi yang sedang aktif
     * Menggunakan root window untuk deteksi yang lebih akurat
     */
    private fun checkCurrentApp() {
        try {
            // Gunakan root window untuk mendapatkan package name yang sedang aktif
            val rootWindow = rootInActiveWindow
            if (rootWindow != null) {
                val packageName = rootWindow.packageName?.toString()
                if (packageName != null) {
                    // Log setiap aplikasi yang dibuka untuk debugging
                    if (blockedPackages.contains(packageName)) {
                        val currentTime = System.currentTimeMillis()
                        if (packageName != lastBlockedPackage || currentTime - lastBlockTime > 500) {
                            Log.w(TAG, "🚫 BLOCKED APP DETECTED: $packageName")
                            blockApp(packageName)
                            lastBlockedPackage = packageName
                            lastBlockTime = currentTime
                        }
                    }
                }
            }
        } catch (e: Exception) {
            // Ignore errors, monitoring akan terus berjalan
            // Accessibility event akan tetap menangkap perubahan aplikasi
            Log.d(TAG, "Error in checkCurrentApp: ${e.message}")
        }
    }
    
    /**
     * Blokir aplikasi dengan metode yang lebih agresif
     * DIPERKUAT: Langsung tutup aplikasi dan tampilkan notifikasi yang jelas
     */
    private fun blockApp(packageName: String) {
        try {
            // DAPATKAN NAMA APLIKASI untuk notifikasi
            val appName = getAppName(packageName)
            
            // LANGSUNG TUTUP APLIKASI PERTAMA (sebelum notifikasi)
            // Method 1: Force back (langsung - PRIORITAS TINGGI)
            performGlobalAction(GLOBAL_ACTION_BACK)
            
            // Method 2: Kembalikan ke home screen SANGAT CEPAT (0ms - langsung)
            performGlobalAction(GLOBAL_ACTION_HOME)
            
            // TAMPILKAN NOTIFIKASI/TOAST SETELAH TUTUP APLIKASI
            handler.post {
                try {
                    val message = "⚠️ $appName sedang diblokir!\n\nAplikasi tidak dapat dibuka. Silakan unblock di halaman Challenge jika ingin menggunakannya kembali."
                    val toast = Toast.makeText(applicationContext, message, Toast.LENGTH_LONG)
                    toast.setGravity(android.view.Gravity.CENTER, 0, 0)
                    toast.show()
                    Log.d(TAG, "Toast shown: $message")
                } catch (e: Exception) {
                    Log.e(TAG, "Error showing toast: ${e.message}", e)
                }
            }
            
            // Method 3: Tampilkan overlay blocking SANGAT CEPAT (20ms)
            handler.postDelayed({
                try {
                    val overlayIntent = Intent(this, BlockingOverlayActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                                Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS or
                                Intent.FLAG_ACTIVITY_NO_HISTORY
                        putExtra("blocked_package", packageName)
                        putExtra("blocked_app_name", appName)
                    }
                    startActivity(overlayIntent)
                    Log.d(TAG, "Overlay shown for: $appName")
                } catch (e: Exception) {
                    Log.e(TAG, "Error showing overlay: ${e.message}", e)
                }
            }, 20)
            
            // Method 4: Pastikan aplikasi tertutup dengan multiple attempts (50ms)
            handler.postDelayed({
                try {
                    val rootWindow = rootInActiveWindow
                    if (rootWindow != null && rootWindow.packageName?.toString() == packageName) {
                        // Jika masih di aplikasi yang diblokir, paksa tutup lagi
                        Log.d(TAG, "App still open, forcing close again: $packageName")
                        performGlobalAction(GLOBAL_ACTION_BACK)
                        performGlobalAction(GLOBAL_ACTION_HOME)
                    }
                } catch (e: Exception) {
                    Log.d(TAG, "Cannot check root window: ${e.message}")
                }
            }, 50)
            
            // Method 5: Force close lagi setelah 100ms untuk memastikan
            handler.postDelayed({
                try {
                    val rootWindow = rootInActiveWindow
                    if (rootWindow != null && rootWindow.packageName?.toString() == packageName) {
                        Log.d(TAG, "App still open after 100ms, forcing close: $packageName")
                        performGlobalAction(GLOBAL_ACTION_HOME)
                        // Tampilkan overlay lagi jika masih terbuka
                        val overlayIntent = Intent(this, BlockingOverlayActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                                    Intent.FLAG_ACTIVITY_SINGLE_TOP
                            putExtra("blocked_package", packageName)
                            putExtra("blocked_app_name", appName)
                        }
                        startActivity(overlayIntent)
                    }
                } catch (e: Exception) {
                    Log.d(TAG, "Error in delayed check: ${e.message}")
                }
            }, 100)
            
            // Method 6: Monitoring berkelanjutan setiap 200ms
            handler.postDelayed({
                checkCurrentApp()
            }, 200)
            
            // Method 7: Final check setelah 500ms
            handler.postDelayed({
                try {
                    val rootWindow = rootInActiveWindow
                    if (rootWindow != null && rootWindow.packageName?.toString() == packageName) {
                        Log.w(TAG, "WARNING: App still open after 500ms! Forcing close: $packageName")
                        performGlobalAction(GLOBAL_ACTION_HOME)
                        // Tampilkan overlay lagi
                        val overlayIntent = Intent(this, BlockingOverlayActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                                    Intent.FLAG_ACTIVITY_SINGLE_TOP
                            putExtra("blocked_package", packageName)
                            putExtra("blocked_app_name", appName)
                        }
                        startActivity(overlayIntent)
                    }
                } catch (e: Exception) {
                    Log.d(TAG, "Error in final check: ${e.message}")
                }
            }, 500)
            
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
    
    /**
     * Dapatkan nama aplikasi dari package name
     */
    private fun getAppName(packageName: String): String {
        return try {
            val pm = packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            Log.e(TAG, "Error getting app name: ${e.message}")
            // Fallback ke nama package atau nama umum
            when (packageName) {
                "com.instagram.android" -> "Instagram"
                "com.zhiliaoapp.musically" -> "TikTok"
                "com.facebook.katana" -> "Facebook"
                "com.snapchat.android" -> "Snapchat"
                "com.google.android.youtube" -> "YouTube"
                "com.twitter.android" -> "Twitter/X"
                else -> "Aplikasi"
            }
        }
    }
    
    override fun onInterrupt() {
        Log.d(TAG, "AppBlockingService interrupted")
        handler.removeCallbacks(monitoringRunnable)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "AppBlockingService destroyed")
        handler.removeCallbacks(monitoringRunnable)
    }
}

