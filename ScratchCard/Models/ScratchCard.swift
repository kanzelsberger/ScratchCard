//
//  ScratchCard.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import Foundation

enum ScratchCardState: Equatable, Sendable {
    case unscratched
    case scratched(code: String)
    case activated(code: String)

    var isUnscratched: Bool {
        if case .unscratched = self { return true }
        return false
    }

    var isScratched: Bool {
        if case .scratched = self { return true }
        return false
    }

    var isActivated: Bool {
        if case .activated = self { return true }
        return false
    }

    var code: String? {
        switch self {
        case .unscratched:
            return nil
        case .scratched(let code), .activated(let code):
            return code
        }
    }

    var displayText: String {
        switch self {
        case .unscratched:
            return "Unscratched"
        case .scratched(let code):
            return "Scratched - Code: \(code)"
        case .activated(let code):
            return "Activated - Code: \(code)"
        }
    }
}

struct VersionResponse: Codable, Equatable, Sendable {
    let ios: String

    init(ios: String) {
        self.ios = ios
    }

    var version: Double? {
        Double(ios)
    }

    func isVersionValid(minimumVersion: Double = 6.1) -> Bool {
        guard let version = version else { return false }
        return version > minimumVersion
    }
}
