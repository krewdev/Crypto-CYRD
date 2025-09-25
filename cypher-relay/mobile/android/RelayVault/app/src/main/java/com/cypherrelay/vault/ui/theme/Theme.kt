package com.cypherrelay.vault.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

// Define colors
val PrimaryColor = Color(0xFF6366F1) // Indigo
val SecondaryColor = Color(0xFF8B5CF6) // Purple
val TertiaryColor = Color(0xFF06B6D4) // Cyan
val SuccessColor = Color(0xFF10B981) // Green
val ErrorColor = Color(0xFFEF4444) // Red
val WarningColor = Color(0xFFF59E0B) // Amber

val PrimaryBackground = Color(0xFFFAFAFA)
val SecondaryBackground = Color(0xFFF3F4F6)
val CardBackground = Color(0xFFFFFFFF)
val PrimaryText = Color(0xFF111827)
val SecondaryText = Color(0xFF6B7280)

val DarkPrimaryBackground = Color(0xFF111827)
val DarkSecondaryBackground = Color(0xFF1F2937)
val DarkCardBackground = Color(0xFF374151)
val DarkPrimaryText = Color(0xFFF9FAFB)
val DarkSecondaryText = Color(0xFF9CA3AF)

private val LightColorScheme = lightColorScheme(
    primary = PrimaryColor,
    onPrimary = Color.White,
    primaryContainer = PrimaryColor.copy(alpha = 0.1f),
    onPrimaryContainer = PrimaryColor,
    secondary = SecondaryColor,
    onSecondary = Color.White,
    secondaryContainer = SecondaryColor.copy(alpha = 0.1f),
    onSecondaryContainer = SecondaryColor,
    tertiary = TertiaryColor,
    onTertiary = Color.White,
    tertiaryContainer = TertiaryColor.copy(alpha = 0.1f),
    onTertiaryContainer = TertiaryColor,
    error = ErrorColor,
    onError = Color.White,
    errorContainer = ErrorColor.copy(alpha = 0.1f),
    onErrorContainer = ErrorColor,
    background = PrimaryBackground,
    onBackground = PrimaryText,
    surface = CardBackground,
    onSurface = PrimaryText,
    surfaceVariant = SecondaryBackground,
    onSurfaceVariant = SecondaryText
)

private val DarkColorScheme = darkColorScheme(
    primary = PrimaryColor,
    onPrimary = Color.White,
    primaryContainer = PrimaryColor.copy(alpha = 0.2f),
    onPrimaryContainer = Color.White,
    secondary = SecondaryColor,
    onSecondary = Color.White,
    secondaryContainer = SecondaryColor.copy(alpha = 0.2f),
    onSecondaryContainer = Color.White,
    tertiary = TertiaryColor,
    onTertiary = Color.White,
    tertiaryContainer = TertiaryColor.copy(alpha = 0.2f),
    onTertiaryContainer = Color.White,
    error = ErrorColor,
    onError = Color.White,
    errorContainer = ErrorColor.copy(alpha = 0.2f),
    onErrorContainer = Color.White,
    background = DarkPrimaryBackground,
    onBackground = DarkPrimaryText,
    surface = DarkCardBackground,
    onSurface = DarkPrimaryText,
    surfaceVariant = DarkSecondaryBackground,
    onSurfaceVariant = DarkSecondaryText
)

@Composable
fun RelayVaultTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }
    
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primary.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}