//
//  MainView.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {
    init(store: StoreOf<MainFeature>) {
        self.store = store
    }

    @Bindable var store: StoreOf<MainFeature>

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Current state display
                VStack(spacing: 16) {
                    Text("Scratch Card Status")
                        .font(.headline)

                    Text(store.scratchCardState.displayText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(stateColor.opacity(0.1))
                                .stroke(stateColor, lineWidth: 2)
                        )
                }
                .padding(.horizontal)

                Spacer()

                // Navigation buttons
                VStack(spacing: 16) {
                    Button {
                        store.send(.scratchButtonTapped)
                    } label: {
                        Text("Scratch Card")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                store.scratchCardState.isUnscratched
                                    ? Color.blue
                                    : Color.gray
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!store.scratchCardState.isUnscratched)

                    Button {
                        store.send(.activationButtonTapped)
                    } label: {
                        Text("Activate Card")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                store.scratchCardState.isScratched
                                    ? Color.green
                                    : Color.gray
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!store.scratchCardState.isScratched)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Scratch Card")
            .sheet(item: $store.scope(state: \.scratch, action: \.scratch)) { store in
                ScratchView(store: store)
            }
            .sheet(item: $store.scope(state: \.activation, action: \.activation)) { store in
                ActivationView(store: store)
            }
        }
    }

    private var stateColor: Color {
        switch store.scratchCardState {
        case .unscratched:
            return .gray
        case .scratched:
            return .blue
        case .activated:
            return .green
        }
    }
}

#Preview {
    MainView(
        store: Store(initialState: MainFeature.State()) {
            MainFeature()
        }
    )
}
