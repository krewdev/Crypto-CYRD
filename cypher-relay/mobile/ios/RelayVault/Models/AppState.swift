import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var isFirstLaunch: Bool = true
    @Published var isScanning: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    init() {
        checkFirstLaunch()
    }
    
    private func checkFirstLaunch() {
        isFirstLaunch = UserDefaults.standard.string(forKey: "userId") == nil
    }
    
    func setUser(_ user: User) {
        currentUser = user
        UserDefaults.standard.set(user.id, forKey: "userId")
        UserDefaults.standard.set(user.deviceId, forKey: "deviceId")
        isFirstLaunch = false
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    func clearError() {
        errorMessage = ""
        showError = false
    }
}