package com.example.project_uas

import android.app.Activity
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.graphics.Color
import android.view.View
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log

/**
 * Activity untuk menampilkan overlay blocking ketika aplikasi yang diblokir dibuka
 */
class BlockingOverlayActivity : Activity() {
    
    companion object {
        private const val TAG = "BlockingOverlay"
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Set window properties untuk overlay
        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        window.statusBarColor = Color.parseColor("#FF4444")
        window.navigationBarColor = Color.parseColor("#FF4444")
        
        val blockedPackage = intent.getStringExtra("blocked_package") ?: "Aplikasi"
        val appName = getAppName(blockedPackage)
        
        // Buat UI blocking
        val rootView = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#FF4444"))
            setPadding(40, 100, 40, 100)
            gravity = android.view.Gravity.CENTER
        }
        
        val iconView = android.widget.TextView(this).apply {
            text = "🚫"
            textSize = 80f
            gravity = android.view.Gravity.CENTER
        }
        
        val titleView = TextView(this).apply {
            text = "Aplikasi Diblokir"
            textSize = 28f
            setTextColor(Color.WHITE)
            gravity = android.view.Gravity.CENTER
            setPadding(0, 20, 0, 10)
        }
        
        val messageView = TextView(this).apply {
            text = "$appName sedang diblokir untuk membantu Anda fokus pada tujuan detox sosial media."
            textSize = 16f
            setTextColor(Color.WHITE)
            gravity = android.view.Gravity.CENTER
            setPadding(0, 10, 0, 30)
        }
        
        val backButton = Button(this).apply {
            text = "Kembali ke Home"
            textSize = 18f
            setBackgroundColor(Color.WHITE)
            setTextColor(Color.parseColor("#FF4444"))
            setPadding(40, 20, 40, 20)
            setOnClickListener {
                finish()
                val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(homeIntent)
            }
        }
        
        rootView.addView(iconView)
        rootView.addView(titleView)
        rootView.addView(messageView)
        rootView.addView(backButton)
        
        setContentView(rootView)
    }
    
    private fun getAppName(packageName: String): String {
        return try {
            val pm = packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            Log.e(TAG, "Error getting app name: ${e.message}")
            packageName
        }
    }
    
    override fun onBackPressed() {
        // Prevent back button
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }
}

