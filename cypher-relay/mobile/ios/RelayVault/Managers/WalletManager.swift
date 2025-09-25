import Foundation
import Combine
import KeychainSwift

class WalletManager: ObservableObject {
    @Published var wallets: [Wallet] = []
    @Published var transactions: [Transaction] = []
    @Published var totalBalanceUSD: Double = 0
    @Published var totalBalanceCYRD: Double = 0
    @Published var isLoading: Bool = false
    @Published var lastRedeemedAmount: String?
    
    private let apiService = APIService.shared
    private let keychain = KeychainSwift()
    private var cancellables = Set<AnyCancellable>()
    
    var activeChains: [String] {
        wallets.filter { $0.balance > 0 }.map { $0.chain.displayName }
    }
    
    func initialize() {
        loadWallets()
        startBalanceUpdates()
    }
    
    func loadWallets() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        
        Task {
            do {
                let wallets = try await apiService.getWallets(userId: userId)
                await MainActor.run {
                    self.wallets = wallets
                    self.calculateTotalBalance()
                }
            } catch {
                print("Failed to load wallets: \(error)")
            }
        }
    }
    
    func redeemCard(qrData: String) async throws -> RedemptionResponse {
        isLoading = true
        defer { isLoading = false }
        
        let deviceId = getOrCreateDeviceId()
        
        let response = try await apiService.redeemCard(
            qrData: qrData,
            deviceId: deviceId,
            platform: "ios"
        )
        
        if response.success, let data = response.data {
            // Store the redeemed amount for success animation
            await MainActor.run {
                self.lastRedeemedAmount = data.amount
            }
            
            // Create user if first redemption
            if UserDefaults.standard.string(forKey: "userId") == nil {
                let user = User(
                    id: data.userId,
                    deviceId: deviceId,
                    settings: UserSettings(),
                    createdAt: Date(),
                    lastActiveAt: Date()
                )
                AppState().setUser(user)
            }
            
            // Reload wallets and transactions
            loadWallets()
            loadTransactions()
        }
        
        return response
    }
    
    func sendCYRD(to address: String, amount: Double, chain: BlockchainNetwork) async throws {
        // Implementation would call API to initiate send transaction
        // This would use the MPC wallet signing
    }
    
    func loadTransactions() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        
        Task {
            do {
                let transactions = try await apiService.getTransactions(userId: userId)
                await MainActor.run {
                    self.transactions = transactions.sorted { $0.createdAt > $1.createdAt }
                }
            } catch {
                print("Failed to load transactions: \(error)")
            }
        }
    }
    
    private func calculateTotalBalance() {
        totalBalanceCYRD = wallets.reduce(0) { $0 + $1.balance }
        totalBalanceUSD = totalBalanceCYRD // Since CYRD is 1:1 with USD
    }
    
    private func startBalanceUpdates() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateBalances()
            }
            .store(in: &cancellables)
    }
    
    private func updateBalances() {
        guard !wallets.isEmpty else { return }
        
        Task {
            do {
                let balances = try await apiService.getBalances(wallets: wallets)
                await MainActor.run {
                    // Update wallet balances
                    for (index, wallet) in self.wallets.enumerated() {
                        if let updatedBalance = balances.first(where: { $0.address == wallet.address }) {
                            self.wallets[index].balance = updatedBalance.balance
                        }
                    }
                    self.calculateTotalBalance()
                }
            } catch {
                print("Failed to update balances: \(error)")
            }
        }
    }
    
    private func getOrCreateDeviceId() -> String {
        if let deviceId = keychain.get("deviceId") {
            return deviceId
        } else {
            let newDeviceId = UUID().uuidString
            keychain.set(newDeviceId, forKey: "deviceId")
            return newDeviceId
        }
    }
    
    // MARK: - MPC Wallet Functions
    
    func initializeMPCWallet(userId: String, chain: BlockchainNetwork) async throws {
        // In production, this would:
        // 1. Call MPC provider to generate key shares
        // 2. Store device share in secure enclave
        // 3. Send cloud share for iCloud backup
        // 4. Return wallet address
    }
    
    func backupToCloud() async throws {
        // Backup MPC key shares to iCloud Keychain
    }
    
    func setupSocialRecovery(contacts: [String]) async throws {
        // Configure social recovery guardians
    }
}