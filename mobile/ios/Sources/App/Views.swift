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
    @State private var showContacts = false
    @State private var showContactsPathway = false
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
            Button("Trusted Contacts") { showContactsPathway = true }
        }
        .padding()
        .sheet(isPresented: $showPathways) { PathwaysView() }
        .sheet(isPresented: $showContacts) { ContactsView() }
        .sheet(isPresented: $showContactsPathway) { ContactsPathwayView(onDone: { showContactsPathway = false; showContacts = true }) }
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

struct ContactsPathwayView: View {
    var onDone: () -> Void
    @State private var error: String?
    var body: some View {
        VStack(spacing: 16) {
            Text("Trusted Contacts").font(.title).bold()
            Text("Add 1–2 people who can approve a recovery.")
            Button("Continue") {
                let body: [String: Any] = [
                    "user_id": UUID().uuidString,
                    "pathway_id": "trusted_contacts",
                    "status": "unlocked"
                ]
                var req = URLRequest(url: URL(string: "http://localhost:8000/pathways/update")!)
                req.httpMethod = "POST"
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpBody = try? JSONSerialization.data(withJSONObject: body)
                URLSession.shared.dataTask(with: req) { _, resp, err in
                    DispatchQueue.main.async {
                        if let err = err { error = err.localizedDescription } else { onDone() }
                    }
                }.resume()
            }
            if let error = error { Text(error).foregroundColor(.red) }
        }.padding()
    }
}

struct ContactsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var method: String = "sms"
    @State private var value: String = ""
    @State private var message: String?
    var body: some View {
        VStack(spacing: 12) {
            Text("Trusted Contacts").font(.title).bold()
            TextField("Name", text: $name).textFieldStyle(.roundedBorder)
            TextField("Phone or Email", text: $value).textFieldStyle(.roundedBorder)
            HStack {
                Button("SMS") { method = "sms" }.buttonStyle(.borderedProminent).tint(method == "sms" ? .blue : .gray)
                Button("Email") { method = "email" }.buttonStyle(.borderedProminent).tint(method == "email" ? .blue : .gray)
            }
            Button("Save") {
                // Simple POST to backend
                let contact = ["name": name, "method": method, "value": value]
                var comps = URLComponents(string: "http://localhost:8000/wallet/contacts")!
                comps.queryItems = [URLQueryItem(name: "user_id", value: UUID().uuidString)]
                var req = URLRequest(url: comps.url!)
                req.httpMethod = "POST"
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpBody = try? JSONSerialization.data(withJSONObject: [contact])
                URLSession.shared.dataTask(with: req) { _, resp, err in
                    DispatchQueue.main.async {
                        if let err = err { message = err.localizedDescription } else { message = "Saved" }
                    }
                }.resume()
            }
            if let message = message { Text(message) }
            Button("Done") { dismiss() }
        }.padding()
    }
}
