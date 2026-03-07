import Foundation

// MARK: - Auth Service

@Observable
final class AuthService: @unchecked Sendable {

    private let api = APIService.shared
    private let userStorageKey = "com.lebaneselearn.currentUser"

    // MARK: - Published State

    private(set) var currentUser: User?
    private(set) var isLoading = false
    private(set) var error: String?

    var isAuthenticated: Bool {
        currentUser != nil
    }

    // MARK: - Init

    init() {
        // Restore cached user from UserDefaults for offline access
        loadCachedUser()
    }

    // MARK: - Preview / Dev Mode

    /// Sign in with a mock user for UI testing in the simulator.
    /// Bypasses the API entirely — no server connection needed.
    func loginAsPreviewUser() {
        let mockUser = User(
            id: "preview-user-001",
            name: "Test User",
            email: "test@lebaneselearn.com",
            totalXP: 2350,
            level: 6,
            levelTitle: "Conversationalist",
            levelProgress: LevelProgress(current: 600, needed: 1050, progress: 0.57),
            streak: 12,
            timezone: "America/Los_Angeles"
        )
        self.currentUser = mockUser
        cacheUser(mockUser)
    }

    // MARK: - Authentication

    /// Log in with email and password. Stores token and user on success.
    func login(email: String, password: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        let body = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await api.post("/api/auth/login", body: body)

        await api.setToken(response.token)
        self.currentUser = response.user
        cacheUser(response.user)
    }

    /// Register a new account. Stores token and user on success.
    func register(name: String, email: String, password: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        let body = RegisterRequest(name: name, email: email, password: password)
        let response: AuthResponse = try await api.post("/api/auth/register", body: body)

        await api.setToken(response.token)
        self.currentUser = response.user
        cacheUser(response.user)
    }

    /// Log out — clears token, cached user, and in-memory state.
    func logout() {
        Task {
            await api.clearToken()
        }
        currentUser = nil
        clearCachedUser()
    }

    /// Fetch the current user profile from the server.
    func fetchCurrentUser() async throws {
        let user: User = try await api.get("/api/auth/me")
        self.currentUser = user
        cacheUser(user)
    }

    /// Check if the stored token is still valid. Called on app launch.
    func checkSession() async {
        guard await api.isAuthenticated else {
            currentUser = nil
            return
        }

        do {
            try await fetchCurrentUser()
        } catch {
            // Token is expired or invalid — clear auth state
            logout()
        }
    }

    // MARK: - User Caching (UserDefaults)

    private func cacheUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userStorageKey)
        }
    }

    private func loadCachedUser() {
        guard let data = UserDefaults.standard.data(forKey: userStorageKey) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        currentUser = try? decoder.decode(User.self, from: data)
    }

    private func clearCachedUser() {
        UserDefaults.standard.removeObject(forKey: userStorageKey)
    }
}

// MARK: - Request Bodies

/// Request body for POST /api/auth/register
private struct RegisterRequest: Codable, Sendable {
    let name: String
    let email: String
    let password: String
}
