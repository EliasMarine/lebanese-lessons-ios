import Foundation

// MARK: - User

struct User: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let email: String
    var totalXP: Int
    var level: Int
    var levelTitle: String
    var levelProgress: LevelProgress
    var streak: Int
    var timezone: String?
}

// MARK: - Level Progress

struct LevelProgress: Codable, Sendable {
    let current: Int
    let needed: Int
    let progress: Double
}

// MARK: - Auth

struct AuthResponse: Codable, Sendable {
    let token: String
    let user: User
}

struct LoginRequest: Codable, Sendable {
    let email: String
    let password: String
}
