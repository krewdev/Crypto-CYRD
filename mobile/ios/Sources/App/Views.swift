import SwiftUI

struct ScanView: View {
    @State private var navigate = false
    @State private var error: String?
    var body: some View {
        VStack(spacing: 0) {
            QRScannerView { code in
                APIClient.shared.redeem { result in
                    switch result {
                    case .success:
                        navigate = true
                    case .failure(let err):
                        error = err.localizedDescription
                    }
                }
            }
            .frame(height: 400)
            VStack(spacing: 12) {
                Text("Scan Your Card").font(.title).bold()
                if let error = error { Text(error).foregroundColor(.red) }
                Button("What is this?") {}
            }.padding()
            NavigationLink("", destination: VaultView(), isActive: $navigate) { EmptyView() }
        }
    }
}

struct VaultView: View {
    @State private var showPathways = false
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("$25.00 USD").font(.largeTitle).bold()
            Text("25 CYRD")
            Text("History").font(.headline)
            Text("Received from Cypher Card")
            HStack {
                Button("Send (Locked)") { showPathways = true }
                Button("Swap (Locked)") { showPathways = true }
                Button("Explore (Locked)") { showPathways = true }
            }
        }
        .padding()
        .sheet(isPresented: $showPathways) { PathwaysView() }
    }
}

struct PathwaysView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 16) {
            Text("Unlock 'Send'").font(.title).bold()
            Text("Crypto addresses are like email, but for money. Always double-check them!")
            Button("Answer: Double-check the address") { dismiss() }
        }
        .padding()
    }
}
