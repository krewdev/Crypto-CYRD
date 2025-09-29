package com.cypherrelay.vault

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            RelayVaultApp()
        }
    }
}

@Composable
fun RelayVaultApp() {
    val navController = rememberNavController()
    Surface(color = MaterialTheme.colorScheme.background) {
        NavHost(navController = navController, startDestination = "scan") {
            composable("scan") { ScanScreen(onRedeemed = { navController.navigate("vault") }) }
            composable("vault") { VaultScreen(onOpenPathways = { navController.navigate("pathways") }, onOpenContacts = { navController.navigate("contacts_pathway") }) }
            composable("pathways") { PathwaysScreen(onDone = { navController.popBackStack() }) }
            composable("contacts_pathway") { ContactsPathway(onContinue = { navController.navigate("contacts") }) }
            composable("contacts") { ContactsScreen(onDone = { navController.popBackStack() }) }
        }
    }
}
