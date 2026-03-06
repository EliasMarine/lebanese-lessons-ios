import Foundation

// MARK: - API Errors

enum APIError: Error, LocalizedError, Sendable {
    case unauthorized
    case networkError(underlying: Error)
    case serverError(statusCode: Int, message: String?)
    case decodingError(underlying: Error)
    case notFound
    case invalidURL
    case noData

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "You are not authorized. Please log in again."
        case .networkError(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "Unknown error")"
        case .decodingError(let underlying):
            return "Failed to process response: \(underlying.localizedDescription)"
        case .notFound:
            return "The requested resource was not found."
        case .invalidURL:
            return "Invalid URL."
        case .noData:
            return "No data received from server."
        }
    }
}

// MARK: - Server Error Response

private struct ServerErrorResponse: Decodable {
    let error: String?
    let message: String?
}

// MARK: - API Service

actor APIService {

    static let shared = APIService()

    let baseURL = "https://arabicisbeautiful.com"

    // TODO: Migrate token storage to Keychain for production security.
    // UserDefaults is NOT secure for auth tokens — this is a development convenience only.
    private let tokenKey = "com.lebaneselearn.authToken"

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    var isAuthenticated: Bool {
        token != nil
    }

    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - Token Management

    func setToken(_ token: String?) {
        self.token = token
    }

    func clearToken() {
        self.token = nil
    }

    // MARK: - Generic Request Methods

    func get<T: Decodable>(_ path: String) async throws -> T {
        let request = try buildRequest(path: path, method: "GET")
        return try await execute(request)
    }

    func post<T: Decodable>(_ path: String, body: (any Encodable)? = nil) async throws -> T {
        var request = try buildRequest(path: path, method: "POST")
        if let body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }
        return try await execute(request)
    }

    func put<T: Decodable>(_ path: String, body: (any Encodable)? = nil) async throws -> T {
        var request = try buildRequest(path: path, method: "PUT")
        if let body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }
        return try await execute(request)
    }

    func delete(_ path: String) async throws {
        let request = try buildRequest(path: path, method: "DELETE")
        let (_, response) = try await performRequest(request)
        try validateResponse(response)
    }

    // MARK: - Request Building

    private func buildRequest(path: String, method: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    // MARK: - Request Execution

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await performRequest(request)
        try validateResponse(response, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(underlying: error)
        }
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.networkError(underlying: error)
        }
    }

    private func validateResponse(_ response: URLResponse, data: Data? = nil) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(underlying: URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        default:
            var message: String?
            if let data {
                let errorResponse = try? decoder.decode(ServerErrorResponse.self, from: data)
                message = errorResponse?.error ?? errorResponse?.message
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: message)
        }
    }
}

// MARK: - AnyEncodable Wrapper

/// Type-erasing wrapper so we can pass any Encodable through the generic post/put methods.
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        self._encode = { encoder in
            try value.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
