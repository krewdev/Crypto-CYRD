import SwiftUI

struct VaultView: View {
    @EnvironmentObject var walletManager: WalletManager
    @EnvironmentObject var pathwayManager: PathwayManager
    @EnvironmentObject var appState: AppState
    
    @State private var selectedTab = 0
    @State private var showSettings = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home/Vault Tab
            NavigationView {
                VaultHomeView()
                    .navigationTitle("Vault")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(Color("PrimaryColor"))
                            }
                        }
                    }
            }
            .tabItem {
                Label("Vault", systemImage: "lock.fill")
            }
            .tag(0)
            
            // Activity Tab
            NavigationView {
                ActivityView()
                    .navigationTitle("Activity")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Activity", systemImage: "clock.arrow.circlepath")
            }
            .tag(1)
            
            // Learn Tab
            NavigationView {
                PathwaysView()
                    .navigationTitle("Learn")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Learn", systemImage: "graduationcap.fill")
            }
            .tag(2)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct VaultHomeView: View {
    @EnvironmentObject var walletManager: WalletManager
    @EnvironmentObject var pathwayManager: PathwayManager
    @State private var showAddFunds = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Balance Card
                BalanceCard()
                    .padding(.horizontal)
                
                // Quick Actions
                VStack(spacing: 16) {
                    Text("Quick Actions")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ActionButton(
                                title: "Send",
                                icon: "paperplane.fill",
                                isLocked: !pathwayManager.isFeatureUnlocked(.send),
                                action: {
                                    if pathwayManager.isFeatureUnlocked(.send) {
                                        // Navigate to send view
                                    } else {
                                        pathwayManager.startPathway(.send)
                                    }
                                }
                            )
                            
                            ActionButton(
                                title: "Receive",
                                icon: "qrcode",
                                isLocked: false,
                                action: {
                                    // Show receive QR
                                }
                            )
                            
                            ActionButton(
                                title: "Swap",
                                icon: "arrow.triangle.2.circlepath",
                                isLocked: !pathwayManager.isFeatureUnlocked(.swap),
                                action: {
                                    if pathwayManager.isFeatureUnlocked(.swap) {
                                        // Navigate to swap view
                                    } else {
                                        pathwayManager.startPathway(.swap)
                                    }
                                }
                            )
                            
                            ActionButton(
                                title: "Add Funds",
                                icon: "plus.circle.fill",
                                isLocked: false,
                                action: {
                                    showAddFunds = true
                                }
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Recent Activity
                if !walletManager.transactions.isEmpty {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Recent Activity")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(destination: ActivityView()) {
                                Text("See All")
                                    .font(.subheadline)
                                    .foregroundColor(Color("PrimaryColor"))
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(walletManager.transactions.prefix(3)) { transaction in
                                TransactionRow(transaction: transaction)
                                
                                if transaction.id != walletManager.transactions.prefix(3).last?.id {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .background(Color("CardBackground"))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                
                // Educational prompt
                if pathwayManager.hasLockedFeatures {
                    EducationalPromptCard()
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showAddFunds) {
            AddFundsView()
        }
        .sheet(item: $pathwayManager.activePathway) { pathway in
            PathwayLessonView(pathway: pathway)
        }
    }
}

struct BalanceCard: View {
    @EnvironmentObject var walletManager: WalletManager
    @State private var showCryptoBalance = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Balance display
            VStack(spacing: 8) {
                Text("Total Balance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("$\(walletManager.totalBalanceUSD, specifier: "%.2f")")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color("PrimaryText"))
                
                if showCryptoBalance {
                    Text("\(walletManager.totalBalanceCYRD, specifier: "%.2f") CYRD")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Toggle button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showCryptoBalance.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: showCryptoBalance ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 14))
                    
                    Text(showCryptoBalance ? "Hide Crypto" : "Show Crypto")
                        .font(.caption)
                }
                .foregroundColor(Color("PrimaryColor"))
            }
            
            // Multi-chain indicator
            if walletManager.activeChains.count > 1 {
                HStack(spacing: 8) {
                    ForEach(walletManager.activeChains, id: \.self) { chain in
                        ChainBadge(chain: chain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color("CardBackground"),
                    Color("CardBackground").opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct ChainBadge: View {
    let chain: String
    
    var chainColor: Color {
        switch chain.lowercased() {
        case "polygon":
            return Color.purple
        case "arbitrum":
            return Color.blue
        case "solana":
            return Color.green
        default:
            return Color.gray
        }
    }
    
    var body: some View {
        Text(chain.capitalized)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(chainColor)
            .cornerRadius(8)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isLocked ? Color.gray.opacity(0.2) : Color("PrimaryColor").opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isLocked ? .gray : Color("PrimaryColor"))
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.gray)
                            .clipShape(Circle())
                            .offset(x: 20, y: -20)
                    }
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isLocked ? .gray : Color("PrimaryText"))
            }
        }
        .disabled(false) // Always enabled to show pathway
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: transaction.icon)
                .font(.system(size: 20))
                .foregroundColor(transaction.type == .received ? .green : .blue)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.type == .received ? "+" : "-")$\(transaction.amountUSD, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.type == .received ? .green : Color("PrimaryText"))
                
                if transaction.status == .pending {
                    Text("Pending")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
    }
}

struct EducationalPromptCard: View {
    @EnvironmentObject var pathwayManager: PathwayManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                
                Text("Unlock More Features")
                    .font(.headline)
                
                Spacer()
            }
            
            Text("Complete quick lessons to unlock sending, swapping, and more advanced features.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                // Navigate to pathways
            }) {
                Text("Start Learning")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("PrimaryColor"))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(16)
    }
}