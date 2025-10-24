//
//  ActivationView.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import SwiftUI
import ComposableArchitecture

struct ActivationView: View {
    @Bindable var store: StoreOf<ActivationFeature>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Text("Card Code")
                        .font(.headline)

                    Text(store.code)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                .padding()

                if store.isActivating {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)

                        Text("Activating...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                }

                Spacer()

                Button {
                    store.send(.activateButtonTapped)
                } label: {
                    Text("Activate")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(store.isActivating ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(store.isActivating)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Activate Card")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .interactiveDismissDisabled(false) // Allow swipe to dismiss even when loading
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    ActivationView(
        store: Store(
            initialState: ActivationFeature.State(code: "ABC123-456")
        ) {
            ActivationFeature()
        }
    )
}
