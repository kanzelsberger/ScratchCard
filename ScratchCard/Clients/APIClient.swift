//
//  APIClient.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import Foundation
import ComposableArchitecture

@DependencyClient struct APIClient: Sendable {
    var request: @Sendable (_ endpoint: APIRoute) async throws -> Data
}

extension APIClient: DependencyKey {

    static let liveValue: APIClient = {
        let session = URLSession.shared

        return APIClient(
            request: { endpoint in
                do {
                    guard var components = URLComponents(
                        url: try endpoint.baseURL.appendingPathComponent(endpoint.path),
                        resolvingAgainstBaseURL: true
                    ) else {
                        throw APIError.invalidURL(message: "Invalid URL components")
                    }

                    components.queryItems = endpoint.queryItems

                    guard let url = components.url else {
                        throw APIError.invalidURL(message: "Invalid URL")
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = endpoint.method.rawValue

                    let (data, response) = try await session.data(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }

                    guard (200...299).contains(httpResponse.statusCode) else {
                        throw APIError.httpError(statusCode: httpResponse.statusCode)
                    }

                    return data
                } catch let error as APIError {
                    throw error
                } catch let error as UnwrappingError {
                    throw APIError.invalidURL(message: error.localizedDescription)
                } catch {
                    throw APIError.transport(message: error.localizedDescription)
                }
            }
        )
    }()

    static let testValue = {
        
        /// This is for now empty as we are not testing API endpoints.
        ///
        /// However in this place we could mock JSON responses for testing, or what I prefer
        /// to do is to add support for HAR files from Charles proxy. Then you can actually
        /// replay real world situations from logs and inspect what happened.
        ///
        /// Can talk more during interview :)
        
        return APIClient(
            request: { endpoint in
                return try "{\"ios\":\"26.0\"}".data(using: .utf8).unwrapped()
            }
        )
    }()
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

extension APIClient {

    /// Generic request method with automatic JSON decoding
    /// Usage: let response: MyModel = try await api.request(.version(code: "123"))
    
    func request<T>(_ endpoint: APIRoute) async throws -> T where T: Decodable & Sendable {
        let data = try await request(endpoint)
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(message: error.localizedDescription)
        }
    }
}

enum APIError: LocalizedError, Equatable, Sendable {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(message: String)
    case invalidURL(message: String)
    case transport(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .invalidURL(let message):
            return message
        case .transport(let message):
            return message
        }
    }
}
