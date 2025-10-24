//
//  ScratchCardApp.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import SwiftUI
import ComposableArchitecture

@main struct ScratchCardApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(store: Store(initialState: MainFeature.State()) {
                MainFeature().withLogger()
            })
        }
    }
}
