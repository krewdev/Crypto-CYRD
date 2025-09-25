import SwiftUI
import CodeScanner

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showScanner = false
    @State private var showWhatIsThis = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color("PrimaryColor"), Color("SecondaryColor")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo and welcome text
                VStack(spacing: 20) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                    
                    Text("Welcome to\nRelay Vault")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Your gateway to simple,\nsecure crypto")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Main CTA button
                Button(action: {
                    showScanner = true
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                        
                        Text("Scan Your Card")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Color("PrimaryColor"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(.white)
                    .cornerRadius(32)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                
                // What is this link
                Button(action: {
                    showWhatIsThis = true
                }) {
                    Text("What is this?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                }
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .sheet(isPresented: $showScanner) {
            CardScannerView()
        }
        .sheet(isPresented: $showWhatIsThis) {
            WhatIsThisView()
        }
    }
}

struct WhatIsThisView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header image
                    Image("ExplainerHeader")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Crypto made simple")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Relay Vault is your personal crypto wallet that makes owning digital currency as easy as using a gift card.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Feature list
                        FeatureRow(
                            icon: "creditcard.fill",
                            title: "Prepaid Cards",
                            description: "Buy Cypher Relay Cards with cash or card - no bank account needed"
                        )
                        
                        FeatureRow(
                            icon: "lock.shield.fill",
                            title: "Your Money, Your Control",
                            description: "Your crypto is stored securely in your own wallet - not on an exchange"
                        )
                        
                        FeatureRow(
                            icon: "graduationcap.fill",
                            title: "Learn as You Go",
                            description: "Unlock features by completing quick lessons - no confusing jargon"
                        )
                        
                        FeatureRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Simple Recovery",
                            description: "Lost your phone? Recover your wallet with cloud backup - no seed phrases"
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color("PrimaryColor"))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}