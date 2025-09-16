import SwiftUI

@main
struct RelayVaultApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var walletManager = WalletManager()
    @StateObject private var pathwayManager = PathwayManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(walletManager)
                .environmentObject(pathwayManager)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Configure appearance
        configureAppearance()
        
        // Initialize managers
        walletManager.initialize()
        pathwayManager.loadPathways()
        
        // Check for existing user
        if UserDefaults.standard.string(forKey: "userId") != nil {
            appState.isFirstLaunch = false
            walletManager.loadWallets()
        }
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color("PrimaryBackground"))
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color("PrimaryText"))]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color("PrimaryText"))]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color("PrimaryBackground"))
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}