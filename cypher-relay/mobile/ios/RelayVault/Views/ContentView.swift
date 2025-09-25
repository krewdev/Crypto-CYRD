import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var walletManager: WalletManager
    
    var body: some View {
        Group {
            if appState.isFirstLaunch {
                OnboardingView()
            } else if appState.isScanning {
                CardScannerView()
            } else {
                VaultView()
            }
        }
        .animation(.easeInOut, value: appState.isFirstLaunch)
        .animation(.easeInOut, value: appState.isScanning)
    }
}