import SwiftUI
import CodeScanner
import AVFoundation

struct CardScannerView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var walletManager: WalletManager
    @Environment(\.dismiss) var dismiss
    
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            // Scanner view
            CodeScannerView(
                codeTypes: [.qr],
                simulatedData: "CYRD:TEST123:25.00:polygon", // For simulator testing
                completion: handleScan
            )
            .ignoresSafeArea()
            
            // Overlay
            VStack {
                // Top bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                // Scanning frame
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 280, height: 280)
                    
                    // Corner accents
                    ForEach(0..<4) { index in
                        CornerAccent()
                            .rotationEffect(.degrees(Double(index) * 90))
                    }
                }
                
                // Instructions
                VStack(spacing: 10) {
                    Text("Scan QR Code")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Position the code within the frame")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 40)
                
                Spacer()
            }
            
            // Processing overlay
            if isProcessing {
                ProcessingOverlay()
            }
            
            // Success animation
            if showSuccess {
                SuccessAnimationView(
                    amount: walletManager.lastRedeemedAmount ?? "0",
                    onComplete: {
                        appState.isFirstLaunch = false
                        appState.isScanning = false
                        dismiss()
                    }
                )
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let scanResult):
            processQRCode(scanResult.string)
        case .failure(let error):
            errorMessage = "Failed to scan QR code. Please try again."
            showError = true
        }
    }
    
    private func processQRCode(_ qrData: String) {
        guard !isProcessing else { return }
        
        isProcessing = true
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        Task {
            do {
                let result = try await walletManager.redeemCard(qrData: qrData)
                
                await MainActor.run {
                    isProcessing = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

struct CornerAccent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.white)
                .frame(width: 40, height: 3)
            
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 3, height: 40)
                
                Spacer()
            }
        }
        .frame(width: 280, height: 280)
    }
}

struct ProcessingOverlay: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Redeeming your card...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
        }
    }
}

struct SuccessAnimationView: View {
    let amount: String
    let onComplete: () -> Void
    
    @State private var showCheckmark = false
    @State private var showAmount = false
    @State private var scale: CGFloat = 0.3
    
    var body: some View {
        ZStack {
            Color("PrimaryColor")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Checkmark animation
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .scaleEffect(scale)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(Color("PrimaryColor"))
                        .opacity(showCheckmark ? 1 : 0)
                }
                
                // Amount text
                VStack(spacing: 10) {
                    Text("Successfully Added")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("$\(amount)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .opacity(showAmount ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.3).delay(0.3)) {
                showCheckmark = true
            }
            
            withAnimation(.easeIn(duration: 0.3).delay(0.6)) {
                showAmount = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
        }
    }
}