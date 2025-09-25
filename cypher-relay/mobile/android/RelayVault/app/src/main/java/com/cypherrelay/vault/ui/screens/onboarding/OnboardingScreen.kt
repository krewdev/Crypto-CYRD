package com.cypherrelay.vault.ui.screens.onboarding

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cypherrelay.vault.R
import com.cypherrelay.vault.ui.components.GradientBackground
import com.cypherrelay.vault.ui.theme.PrimaryColor
import com.cypherrelay.vault.ui.theme.SecondaryColor

@Composable
fun OnboardingScreen(
    onScanCard: () -> Unit
) {
    var showWhatIsThis by remember { mutableStateOf(false) }
    
    Box(
        modifier = Modifier.fillMaxSize()
    ) {
        // Gradient background
        GradientBackground()
        
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceEvenly
        ) {
            Spacer(modifier = Modifier.height(40.dp))
            
            // Logo and welcome text
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(20.dp)
            ) {
                // App Logo
                Box(
                    modifier = Modifier
                        .size(120.dp)
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.2f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        painter = painterResource(id = R.drawable.ic_vault),
                        contentDescription = "Relay Vault Logo",
                        modifier = Modifier.size(80.dp),
                        tint = Color.White
                    )
                }
                
                Text(
                    text = "Welcome to\nRelay Vault",
                    fontSize = 36.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    textAlign = TextAlign.Center,
                    lineHeight = 42.sp
                )
                
                Text(
                    text = "Your gateway to simple,\nsecure crypto",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.White.copy(alpha = 0.9f),
                    textAlign = TextAlign.Center
                )
            }
            
            Spacer(modifier = Modifier.height(40.dp))
            
            // Main CTA button
            Button(
                onClick = onScanCard,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(64.dp)
                    .shadow(10.dp, RoundedCornerShape(32.dp)),
                shape = RoundedCornerShape(32.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White
                )
            ) {
                Icon(
                    imageVector = Icons.Default.CameraAlt,
                    contentDescription = null,
                    modifier = Modifier.size(24.dp),
                    tint = PrimaryColor
                )
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    text = "Scan Your Card",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = PrimaryColor
                )
            }
            
            // What is this link
            Text(
                text = "What is this?",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
                color = Color.White.copy(alpha = 0.8f),
                textDecoration = TextDecoration.Underline,
                modifier = Modifier.clickable { showWhatIsThis = true }
            )
            
            Spacer(modifier = Modifier.height(50.dp))
        }
        
        // What is this bottom sheet
        if (showWhatIsThis) {
            WhatIsThisBottomSheet(
                onDismiss = { showWhatIsThis = false }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WhatIsThisBottomSheet(
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            Text(
                text = "Crypto made simple",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold
            )
            
            Text(
                text = "Relay Vault is your personal crypto wallet that makes owning digital currency as easy as using a gift card.",
                fontSize = 16.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            // Feature list
            FeatureRow(
                icon = R.drawable.ic_card,
                title = "Prepaid Cards",
                description = "Buy Cypher Relay Cards with cash or card - no bank account needed"
            )
            
            FeatureRow(
                icon = R.drawable.ic_lock_shield,
                title = "Your Money, Your Control",
                description = "Your crypto is stored securely in your own wallet - not on an exchange"
            )
            
            FeatureRow(
                icon = R.drawable.ic_graduation_cap,
                title = "Learn as You Go",
                description = "Unlock features by completing quick lessons - no confusing jargon"
            )
            
            FeatureRow(
                icon = R.drawable.ic_recovery,
                title = "Simple Recovery",
                description = "Lost your phone? Recover your wallet with cloud backup - no seed phrases"
            )
            
            Spacer(modifier = Modifier.height(20.dp))
            
            Button(
                onClick = onDismiss,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                shape = RoundedCornerShape(24.dp)
            ) {
                Text("Got it")
            }
            
            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}

@Composable
fun FeatureRow(
    icon: Int,
    title: String,
    description: String
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(PrimaryColor.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                painter = painterResource(id = icon),
                contentDescription = null,
                modifier = Modifier.size(24.dp),
                tint = PrimaryColor
            )
        }
        
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = title,
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            )
            
            Text(
                text = description,
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}