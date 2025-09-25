import Foundation
import Alamofire

class APIService {
    static let shared = APIService()
    
    private let baseURL = ProcessInfo.processInfo.environment["API_URL"] ?? "https://api.cypherrelay.com"
    private let session: Session
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = true
        
        session = Session(configuration: configuration)
    }
    
    // MARK: - Card Redemption
    
    func redeemCard(qrData: String, deviceId: String, platform: String) async throws -> RedemptionResponse {
        let parameters: [String: Any] = [
            "qrData": qrData,
            "deviceId": deviceId,
            "platform": platform,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request("\(baseURL)/api/cards/redeem",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
                .validate()
                .responseDecodable(of: RedemptionResponse.self) { response in
                    switch response.result {
                    case .success(let redemptionResponse):
                        continuation.resume(returning: redemptionResponse)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
        }
    }
    
    func verifyQRCode(qrData: String) async throws -> Bool {
        let parameters = ["qrData": qrData]
        
        struct VerifyResponse: Decodable {
            let valid: Bool
            let error: String?
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request("\(baseURL)/api/cards/verify",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
                .validate()
                .responseDecodable(of: VerifyResponse.self) { response in
                    switch response.result {
                    case .success(let verifyResponse):
                        continuation.resume(returning: verifyResponse.valid)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
        }
    }
    
    // MARK: - Wallet Management
    
    func getWallets(userId: String) async throws -> [Wallet] {
        return try await withCheckedThrowingContinuation { continuation in
            session.request("\(baseURL)/api/wallets/\(userId)")
                .validate()
                .responseDecodable(of: [Wallet].self, decoder: JSONDecoder.apiDecoder) { response in
                    switch response.result {
                    case .success(let wallets):
                        continuation.resume(returning: wallets)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
        }
    }
    
    func getBalances(wallets: [Wallet]) async throws -> [ChainBalance] {
        let addresses = wallets.map { ["chain": $0.chain.rawValue, "address": $0.address] }
        let parameters = ["wallets": addresses]
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request("\(baseURL)/api/wallets/balances",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
                .validate()
                .responseDecodable(of: BalanceResponse.self) { response in
                    switch response.result {
                    case .success(let balanceResponse):
                        continuation.resume(returning: balanceResponse.balances)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
        }
    }
    
    // MARK: - Transactions
    
    func getTransactions(userId: String, limit: Int = 50) async throws -> [Transaction] {
        let parameters = ["limit": limit]
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request("\(baseURL)/api/users/\(userId)/transactions",
                          parameters: parameters)
                .validate()
                .responseDecodable(of: [Transaction].self, decoder: JSONDecoder.apiDecoder) { response in
                    switch response.result {
                    case .success(let transactions):
                        continuation.resume(returning: transactions)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
        }
    }
    
    func sendTransaction(from: String, to: String, amount: Double, chain: BlockchainNetwork) async throws -> Transaction {
        let parameters: [String: Any] = [
            "fromAddress": from,
            "toAddress": to,
            "amount": amount,
            "chain": chain.rawValue
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request("\(baseURL)/api/transactions/send",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
                .validate()
                .responseDecodable(of: Transaction.self, decoder: JSONDecoder.apiDecoder) { response in
                    switch response.result {
                    case .success(let transaction):
                        continuation.resume(returning: transaction)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
        }
    }
    
    // MARK: - Pathways
    
    func getPathwayProgress(userId: String) async throws -> [PathwayProgressResponse] {
        struct PathwayProgressResponse: Decodable {
            let pathwayId: String
            let status: String
            let currentStep: Int
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request("\(baseURL)/api/pathways/progress/\(userId)")
                .validate()
                .responseDecodable(of: [PathwayProgressResponse].self) { response in
                    switch response.result {
                    case .success(let progress):
                        continuation.resume(returning: progress)
                    case .failure(let error):
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
        }
    }
    
    func updatePathwayProgress(userId: String, progress: [[String: Any]]) async throws {
        let parameters = ["progress": progress]
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request("\(baseURL)/api/pathways/progress/\(userId)",
                          method: .put,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
                .validate()
                .response { response in
                    if let error = response.error {
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    } else {
                        continuation.resume()
                    }
                }
        }
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: AFError, response: HTTPURLResponse?) -> Error {
        if let statusCode = response?.statusCode {
            switch statusCode {
            case 400:
                return APIError.badRequest
            case 401:
                return APIError.unauthorized
            case 404:
                return APIError.notFound
            case 429:
                return APIError.rateLimited
            case 500...599:
                return APIError.serverError
            default:
                return error
            }
        }
        
        if case .sessionTaskFailed(let urlError as URLError) = error {
            if urlError.code == .notConnectedToInternet {
                return APIError.noConnection
            }
        }
        
        return error
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case badRequest
    case unauthorized
    case notFound
    case rateLimited
    case serverError
    case noConnection
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return "Invalid request. Please try again."
        case .unauthorized:
            return "Authentication failed. Please restart the app."
        case .notFound:
            return "The requested resource was not found."
        case .rateLimited:
            return "Too many requests. Please wait a moment."
        case .serverError:
            return "Server error. Please try again later."
        case .noConnection:
            return "No internet connection. Please check your network."
        case .invalidResponse:
            return "Invalid response from server."
        }
    }
}

// MARK: - JSON Decoder Extension

extension JSONDecoder {
    static let apiDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}