import Foundation
import SwiftUI

class PathwayManager: ObservableObject {
    @Published var pathways: [Pathway] = []
    @Published var activePathway: Pathway?
    @Published var unlockedFeatures: Set<UnlockableFeature> = []
    
    private let apiService = APIService.shared
    
    var hasLockedFeatures: Bool {
        pathways.contains { $0.status == .locked || $0.status == .available }
    }
    
    func loadPathways() {
        // Load pathways from local JSON and sync with server
        loadLocalPathways()
        syncWithServer()
    }
    
    func isFeatureUnlocked(_ feature: UnlockableFeature) -> Bool {
        unlockedFeatures.contains(feature)
    }
    
    func startPathway(_ feature: UnlockableFeature) {
        guard let pathway = pathways.first(where: { $0.feature == feature }) else { return }
        activePathway = pathway
    }
    
    func completeLesson(pathwayId: String, lessonIndex: Int) {
        guard let index = pathways.firstIndex(where: { $0.id == pathwayId }) else { return }
        
        pathways[index].currentStep = lessonIndex + 1
        pathways[index].status = .inProgress
        
        if lessonIndex == pathways[index].lessons.count - 1 {
            completePathway(pathwayId: pathwayId)
        }
    }
    
    func submitQuizAnswer(pathwayId: String, lessonIndex: Int, answerId: String) -> Bool {
        guard let pathway = pathways.first(where: { $0.id == pathwayId }),
              let lesson = pathway.lessons[safe: lessonIndex],
              let quiz = lesson.quiz else { return false }
        
        let isCorrect = quiz.correctAnswerId == answerId
        
        if isCorrect {
            completeLesson(pathwayId: pathwayId, lessonIndex: lessonIndex)
        }
        
        return isCorrect
    }
    
    private func completePathway(pathwayId: String) {
        guard let index = pathways.firstIndex(where: { $0.id == pathwayId }) else { return }
        
        pathways[index].status = .completed
        pathways[index].completedAt = Date()
        unlockedFeatures.insert(pathways[index].feature)
        
        // Save to server
        saveProgress()
        
        // Close active pathway
        if activePathway?.id == pathwayId {
            activePathway = nil
        }
    }
    
    private func loadLocalPathways() {
        // Create default pathways
        pathways = [
            createSendPathway(),
            createSwapPathway(),
            createSecurityPathway(),
            createNetworkFeesPathway()
        ]
        
        // Load saved progress
        loadSavedProgress()
    }
    
    private func createSendPathway() -> Pathway {
        Pathway(
            id: "send_pathway",
            title: "Unlock Send",
            description: "Learn how to safely send crypto to others",
            icon: "paperplane.fill",
            feature: .send,
            status: .available,
            totalSteps: 3,
            currentStep: 0,
            estimatedMinutes: 1,
            lessons: [
                PathwayLesson(
                    id: "send_1",
                    title: "Crypto Addresses",
                    content: [
                        LessonContent(
                            type: .text,
                            text: "Crypto addresses are like email addresses, but for money. Each blockchain has its own format.",
                            imageName: nil,
                            animation: nil
                        ),
                        LessonContent(
                            type: .image,
                            text: nil,
                            imageName: "address_example",
                            animation: nil
                        ),
                        LessonContent(
                            type: .text,
                            text: "Always double-check addresses before sending. Transactions can't be reversed!",
                            imageName: nil,
                            animation: nil
                        )
                    ],
                    quiz: nil
                ),
                PathwayLesson(
                    id: "send_2",
                    title: "Network Fees",
                    content: [
                        LessonContent(
                            type: .text,
                            text: "Every transaction requires a small network fee. This fee goes to the network validators, not to us.",
                            imageName: nil,
                            animation: nil
                        ),
                        LessonContent(
                            type: .text,
                            text: "Fees vary by network:\n• Polygon: ~$0.01\n• Arbitrum: ~$0.10\n• Ethereum: $2-20+",
                            imageName: nil,
                            animation: nil
                        )
                    ],
                    quiz: nil
                ),
                PathwayLesson(
                    id: "send_3",
                    title: "Safety Check",
                    content: [
                        LessonContent(
                            type: .text,
                            text: "Let's make sure you're ready to send crypto safely!",
                            imageName: nil,
                            animation: nil
                        )
                    ],
                    quiz: PathwayQuiz(
                        question: "What should you always do before sending crypto?",
                        options: [
                            QuizOption(id: "a", text: "Send immediately to save time"),
                            QuizOption(id: "b", text: "Double-check the recipient address"),
                            QuizOption(id: "c", text: "Send a test transaction first"),
                            QuizOption(id: "d", text: "Both B and C")
                        ],
                        correctAnswerId: "d",
                        explanation: "Always double-check addresses and consider sending a small test amount first for large transactions."
                    )
                )
            ]
        )
    }
    
    private func createSwapPathway() -> Pathway {
        Pathway(
            id: "swap_pathway",
            title: "Unlock Swap",
            description: "Learn how to exchange between different cryptocurrencies",
            icon: "arrow.triangle.2.circlepath",
            feature: .swap,
            status: .locked,
            totalSteps: 3,
            currentStep: 0,
            estimatedMinutes: 2,
            lessons: [
                PathwayLesson(
                    id: "swap_1",
                    title: "What is Swapping?",
                    content: [
                        LessonContent(
                            type: .text,
                            text: "Swapping lets you exchange one cryptocurrency for another, like trading baseball cards!",
                            imageName: nil,
                            animation: nil
                        ),
                        LessonContent(
                            type: .text,
                            text: "You can swap your CYRD for other popular cryptocurrencies like ETH, MATIC, or USDC.",
                            imageName: nil,
                            animation: nil
                        )
                    ],
                    quiz: nil
                ),
                PathwayLesson(
                    id: "swap_2",
                    title: "Exchange Rates",
                    content: [
                        LessonContent(
                            type: .text,
                            text: "Exchange rates change constantly based on supply and demand, just like foreign currency exchange.",
                            imageName: nil,
                            animation: nil
                        ),
                        LessonContent(
                            type: .text,
                            text: "The app will always show you the current rate before you confirm a swap.",
                            imageName: nil,
                            animation: nil
                        )
                    ],
                    quiz: nil
                ),
                PathwayLesson(
                    id: "swap_3",
                    title: "Swap Safely",
                    content: [
                        LessonContent(
                            type: .text,
                            text: "Ready to test your swap knowledge?",
                            imageName: nil,
                            animation: nil
                        )
                    ],
                    quiz: PathwayQuiz(
                        question: "What should you check before confirming a swap?",
                        options: [
                            QuizOption(id: "a", text: "The exchange rate"),
                            QuizOption(id: "b", text: "The network fee"),
                            QuizOption(id: "c", text: "The amount you'll receive"),
                            QuizOption(id: "d", text: "All of the above")
                        ],
                        correctAnswerId: "d",
                        explanation: "Always review the rate, fees, and final amount before swapping."
                    )
                )
            ]
        )
    }
    
    private func createSecurityPathway() -> Pathway {
        Pathway(
            id: "security_pathway",
            title: "Advanced Security",
            description: "Set up recovery options and enhance your vault security",
            icon: "lock.shield.fill",
            feature: .advancedSecurity,
            status: .locked,
            totalSteps: 4,
            currentStep: 0,
            estimatedMinutes: 3,
            lessons: [] // Add lessons
        )
    }
    
    private func createNetworkFeesPathway() -> Pathway {
        Pathway(
            id: "fees_pathway",
            title: "Understanding Fees",
            description: "Learn about network fees and how to save money",
            icon: "dollarsign.circle.fill",
            feature: .send, // Uses same feature as send
            status: .available,
            totalSteps: 2,
            currentStep: 0,
            estimatedMinutes: 1,
            lessons: [] // Add lessons
        )
    }
    
    private func syncWithServer() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        
        Task {
            do {
                let progress = try await apiService.getPathwayProgress(userId: userId)
                await MainActor.run {
                    // Update local pathways with server progress
                    for serverProgress in progress {
                        if let index = pathways.firstIndex(where: { $0.id == serverProgress.pathwayId }) {
                            pathways[index].status = PathwayStatus(rawValue: serverProgress.status) ?? .locked
                            pathways[index].currentStep = serverProgress.currentStep
                            
                            if pathways[index].status == .completed {
                                unlockedFeatures.insert(pathways[index].feature)
                            }
                        }
                    }
                }
            } catch {
                print("Failed to sync pathway progress: \(error)")
            }
        }
    }
    
    private func saveProgress() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        
        Task {
            do {
                let progress = pathways.map { pathway in
                    [
                        "pathwayId": pathway.id,
                        "status": pathway.status.rawValue,
                        "currentStep": pathway.currentStep
                    ]
                }
                
                try await apiService.updatePathwayProgress(userId: userId, progress: progress)
            } catch {
                print("Failed to save pathway progress: \(error)")
            }
        }
    }
    
    private func loadSavedProgress() {
        // Load from UserDefaults for offline support
        if let savedFeatures = UserDefaults.standard.array(forKey: "unlockedFeatures") as? [String] {
            unlockedFeatures = Set(savedFeatures.compactMap { UnlockableFeature(rawValue: $0) })
        }
    }
}

// Safe array subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}