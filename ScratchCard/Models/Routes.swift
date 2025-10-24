//
//  Routes.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import Foundation

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var baseURL: URL? { get }
}

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIRoute: Sendable {
    case version(code: String)
}

extension APIRoute: APIEndpoint {
    var baseURL: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.o2.sk"
        return components.url
    }

    var path: String {
        switch self {
        case .version:
            return "/version"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .version(let code):
            return [URLQueryItem(name: "code", value: code)]
        }
    }
}
