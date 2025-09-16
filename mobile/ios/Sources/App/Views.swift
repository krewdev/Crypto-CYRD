import SwiftUI

struct ScanView: View {
    @State private var navigate = false
    var body: some View {
        VStack(spacing: 16) {
            Text("Scan Your Card").font(.title).bold()
            Button("Simulate Redeem") { navigate = true }
            Button("What is this?") {}
            NavigationLink("", destination: VaultView(), isActive: $navigate) { EmptyView() }
        }
        .padding()
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
