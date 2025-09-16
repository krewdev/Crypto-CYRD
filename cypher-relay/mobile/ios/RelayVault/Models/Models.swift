import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let deviceId: String
    let platform: String = "ios"
    var kycTier: Int = 0
    var totalRedeemed: Double = 0
    var settings: UserSettings
    var createdAt: Date
    var lastActiveAt: Date
}

struct UserSettings: Codable {
    var currency: String = "USD"
    var notifications: Bool = true
    var biometricEnabled: Bool = false
}

// MARK: - Wallet Model
struct Wallet: Codable, Identifiable {
    let id: String
    let userId: String
    let chain: BlockchainNetwork
    let address: String
    var balance: Double
    var isActive: Bool = true
    let createdAt: Date
}

enum BlockchainNetwork: String, Codable, CaseIterable {
    case polygon = "polygon"
    case arbitrum = "arbitrum"
    case solana = "solana"
    case ethereum = "ethereum"
    case avalanche = "avalanche"
    case bsc = "bsc"
    
    var displayName: String {
        switch self {
        case .polygon: return "Polygon"
        case .arbitrum: return "Arbitrum"
        case .solana: return "Solana"
        case .ethereum: return "Ethereum"
        case .avalanche: return "Avalanche"
        case .bsc: return "BNB Chain"
        }
    }
    
    var color: String {
        switch self {
        case .polygon: return "#8247E5"
        case .arbitrum: return "#28A0F0"
        case .solana: return "#00FFA3"
        case .ethereum: return "#627EEA"
        case .avalanche: return "#E84142"
        case .bsc: return "#F3BA2F"
        }
    }
}

// MARK: - Transaction Model
struct Transaction: Codable, Identifiable {
    let id: String
    let userId: String
    let type: TransactionType
    let chain: String
    let txHash: String?
    var status: TransactionStatus
    let fromAddress: String?
    let toAddress: String?
    let tokenSymbol: String
    let amount: Double
    let amountUSD: Double
    let fee: Double?
    let description: String
    let createdAt: Date
    var confirmedAt: Date?
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var icon: String {
        switch type {
        case .redemption:
            return "creditcard.fill"
        case .sent:
            return "paperplane.fill"
        case .received:
            return "arrow.down.circle.fill"
        case .swap:
            return "arrow.triangle.2.circlepath"
        case .bridge:
            return "arrow.left.arrow.right"
        }
    }
}

enum TransactionType: String, Codable {
    case redemption = "redemption"
    case sent = "send"
    case received = "receive"
    case swap = "swap"
    case bridge = "bridge"
}

enum TransactionStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case failed = "failed"
}

// MARK: - Card Model
struct Card: Codable {
    let cardId: String
    let value: Double
    let tokenAmount: Double
    let nativeChain: BlockchainNetwork
    let isRedeemed: Bool
    let expiresAt: Date?
}

// MARK: - Pathway Model
struct Pathway: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let feature: UnlockableFeature
    var status: PathwayStatus
    let totalSteps: Int
    var currentStep: Int
    let estimatedMinutes: Int
    var startedAt: Date?
    var completedAt: Date?
    let lessons: [PathwayLesson]
}

enum UnlockableFeature: String, Codable {
    case send = "send"
    case swap = "swap"
    case bridge = "bridge"
    case advancedSecurity = "advanced_security"
    case defi = "defi"
}

enum PathwayStatus: String, Codable {
    case locked = "locked"
    case available = "available"
    case inProgress = "in_progress"
    case completed = "completed"
}

struct PathwayLesson: Codable, Identifiable {
    let id: String
    let title: String
    let content: [LessonContent]
    let quiz: PathwayQuiz?
}

struct LessonContent: Codable {
    let type: ContentType
    let text: String?
    let imageName: String?
    let animation: String?
    
    enum ContentType: String, Codable {
        case text
        case image
        case animation
        case interactive
    }
}

struct PathwayQuiz: Codable {
    let question: String
    let options: [QuizOption]
    let correctAnswerId: String
    let explanation: String
}

struct QuizOption: Codable, Identifiable {
    let id: String
    let text: String
}

// MARK: - API Response Models
struct RedemptionResponse: Codable {
    let success: Bool
    let data: RedemptionData?
    let error: String?
}

struct RedemptionData: Codable {
    let userId: String
    let walletAddress: String
    let chain: String
    let amount: String
    let tokenAmount: String
    let txHash: String
    let message: String
}

struct BalanceResponse: Codable {
    let balances: [ChainBalance]
    let totalUSD: Double
}

struct ChainBalance: Codable {
    let chain: String
    let address: String
    let balance: Double
    let usdValue: Double
}