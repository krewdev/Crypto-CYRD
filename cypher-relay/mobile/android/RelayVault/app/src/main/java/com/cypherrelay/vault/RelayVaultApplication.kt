package com.cypherrelay.vault

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class RelayVaultApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // Initialize any app-wide configurations here
        initializeSecurityProvider()
    }
    
    private fun initializeSecurityProvider() {
        // Initialize security providers for crypto operations
        try {
            // AndroidKeyStore initialization happens automatically
        } catch (e: Exception) {
            // Log error but don't crash the app
            e.printStackTrace()
        }
    }
}