package com.cypherrelay.vault.data.models

import kotlinx.serialization.Serializable
import java.util.Date

// User Models
@Serializable
data class User(
    val id: String,
    val deviceId: String,
    val platform: String = "android",
    val kycTier: Int = 0,
    val totalRedeemed: Double = 0.0,
    val settings: UserSettings = UserSettings(),
    val createdAt: Long = System.currentTimeMillis(),
    val lastActiveAt: Long = System.currentTimeMillis()
)

@Serializable
data class UserSettings(
    val currency: String = "USD",
    val notifications: Boolean = true,
    val biometricEnabled: Boolean = false
)

// Wallet Models
@Serializable
data class Wallet(
    val id: String,
    val userId: String,
    val chain: BlockchainNetwork,
    val address: String,
    val balance: Double = 0.0,
    val isActive: Boolean = true,
    val createdAt: Long = System.currentTimeMillis()
)

enum class BlockchainNetwork(val displayName: String, val color: String) {
    POLYGON("Polygon", "#8247E5"),
    ARBITRUM("Arbitrum", "#28A0F0"),
    SOLANA("Solana", "#00FFA3"),
    ETHEREUM("Ethereum", "#627EEA"),
    AVALANCHE("Avalanche", "#E84142"),
    BSC("BNB Chain", "#F3BA2F")
}

// Transaction Models
@Serializable
data class Transaction(
    val id: String,
    val userId: String,
    val type: TransactionType,
    val chain: String,
    val txHash: String? = null,
    val status: TransactionStatus,
    val fromAddress: String? = null,
    val toAddress: String? = null,
    val tokenSymbol: String,
    val amount: Double,
    val amountUSD: Double,
    val fee: Double? = null,
    val description: String,
    val createdAt: Long,
    val confirmedAt: Long? = null
) {
    val icon: Int
        get() = when (type) {
            TransactionType.REDEMPTION -> R.drawable.ic_card
            TransactionType.SENT -> R.drawable.ic_send
            TransactionType.RECEIVED -> R.drawable.ic_receive
            TransactionType.SWAP -> R.drawable.ic_swap
            TransactionType.BRIDGE -> R.drawable.ic_bridge
        }
}

enum class TransactionType {
    REDEMPTION,
    SENT,
    RECEIVED,
    SWAP,
    BRIDGE
}

enum class TransactionStatus {
    PENDING,
    CONFIRMED,
    FAILED
}

// Card Models
@Serializable
data class Card(
    val cardId: String,
    val value: Double,
    val tokenAmount: Double,
    val nativeChain: BlockchainNetwork,
    val isRedeemed: Boolean,
    val expiresAt: Long? = null
)

// Pathway Models
@Serializable
data class Pathway(
    val id: String,
    val title: String,
    val description: String,
    val icon: String,
    val feature: UnlockableFeature,
    val status: PathwayStatus,
    val totalSteps: Int,
    val currentStep: Int,
    val estimatedMinutes: Int,
    val startedAt: Long? = null,
    val completedAt: Long? = null,
    val lessons: List<PathwayLesson>
)

enum class UnlockableFeature {
    SEND,
    SWAP,
    BRIDGE,
    ADVANCED_SECURITY,
    DEFI
}

enum class PathwayStatus {
    LOCKED,
    AVAILABLE,
    IN_PROGRESS,
    COMPLETED
}

@Serializable
data class PathwayLesson(
    val id: String,
    val title: String,
    val content: List<LessonContent>,
    val quiz: PathwayQuiz? = null
)

@Serializable
data class LessonContent(
    val type: ContentType,
    val text: String? = null,
    val imageName: String? = null,
    val animation: String? = null
)

enum class ContentType {
    TEXT,
    IMAGE,
    ANIMATION,
    INTERACTIVE
}

@Serializable
data class PathwayQuiz(
    val question: String,
    val options: List<QuizOption>,
    val correctAnswerId: String,
    val explanation: String
)

@Serializable
data class QuizOption(
    val id: String,
    val text: String
)

// API Response Models
@Serializable
data class RedemptionResponse(
    val success: Boolean,
    val data: RedemptionData? = null,
    val error: String? = null
)

@Serializable
data class RedemptionData(
    val userId: String,
    val walletAddress: String,
    val chain: String,
    val amount: String,
    val tokenAmount: String,
    val txHash: String,
    val message: String
)

@Serializable
data class BalanceResponse(
    val balances: List<ChainBalance>,
    val totalUSD: Double
)

@Serializable
data class ChainBalance(
    val chain: String,
    val address: String,
    val balance: Double,
    val usdValue: Double
)