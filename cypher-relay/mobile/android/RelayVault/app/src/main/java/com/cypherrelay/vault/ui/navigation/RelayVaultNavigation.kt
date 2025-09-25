package com.cypherrelay.vault.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.cypherrelay.vault.ui.screens.home.HomeScreen
import com.cypherrelay.vault.ui.screens.onboarding.OnboardingScreen
import com.cypherrelay.vault.ui.screens.scanner.CardScannerScreen
import com.cypherrelay.vault.ui.screens.vault.VaultScreen
import com.cypherrelay.vault.ui.viewmodels.AppStateViewModel

@Composable
fun RelayVaultNavigation() {
    val navController = rememberNavController()
    val appStateViewModel: AppStateViewModel = hiltViewModel()
    val isFirstLaunch by appStateViewModel.isFirstLaunch.collectAsState()
    
    val startDestination = if (isFirstLaunch) {
        Screen.Onboarding.route
    } else {
        Screen.Vault.route
    }
    
    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        composable(Screen.Onboarding.route) {
            OnboardingScreen(
                onScanCard = {
                    navController.navigate(Screen.Scanner.route)
                }
            )
        }
        
        composable(Screen.Scanner.route) {
            CardScannerScreen(
                onCardRedeemed = {
                    appStateViewModel.setFirstLaunchComplete()
                    navController.navigate(Screen.Vault.route) {
                        popUpTo(0) { inclusive = true }
                    }
                },
                onBack = {
                    navController.popBackStack()
                }
            )
        }
        
        composable(Screen.Vault.route) {
            VaultScreen(
                onScanNewCard = {
                    navController.navigate(Screen.Scanner.route)
                }
            )
        }
        
        composable(Screen.Home.route) {
            HomeScreen()
        }
    }
}

sealed class Screen(val route: String) {
    object Onboarding : Screen("onboarding")
    object Scanner : Screen("scanner")
    object Vault : Screen("vault")
    object Home : Screen("home")
    object Send : Screen("send/{address}")
    object Receive : Screen("receive")
    object Swap : Screen("swap")
    object Activity : Screen("activity")
    object Pathways : Screen("pathways")
    object PathwayLesson : Screen("pathway/{pathwayId}")
    object Settings : Screen("settings")
}