import Foundation

struct RedeemRequest: Codable {
    let device_id: String
    let qr_code: String
    let chain: String
}

struct RedeemResponse: Codable {
    let success: Bool
    let user_id: String
    let wallet_address: String?
    let amount_cyrd: Int
    let message: String
}

enum APIError: Error { case invalidURL, network(Error), badStatus(Int) }

class APIClient {
    static let shared = APIClient()
    var baseURL = URL(string: "http://localhost:8000")!

    func redeem(completion: @escaping (Result<RedeemResponse, Error>) -> Void) {
        let req = RedeemRequest(device_id: UUID().uuidString, qr_code: "SIMULATED-QR-CODE", chain: "polygon")
        guard let url = URL(string: "/redeem", relativeTo: baseURL) else { completion(.failure(APIError.invalidURL)); return }
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "POST"
        urlReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq.httpBody = try? JSONEncoder().encode(req)
        URLSession.shared.dataTask(with: urlReq) { data, resp, err in
            if let err = err { completion(.failure(APIError.network(err))); return }
            guard let http = resp as? HTTPURLResponse else { completion(.failure(APIError.invalidURL)); return }
            guard (200..<300).contains(http.statusCode) else { completion(.failure(APIError.badStatus(http.statusCode))); return }
            if let data = data, let res = try? JSONDecoder().decode(RedeemResponse.self, from: data) {
                completion(.success(res))
            } else {
                completion(.failure(APIError.invalidURL))
            }
        }.resume()
    }
}
