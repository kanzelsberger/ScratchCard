//
//  ScratchView.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import SwiftUI
import ComposableArchitecture

struct ScratchView: View {
    @Bindable var store: StoreOf<ScratchFeature>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                if let code = store.revealedCode {
                    VStack(spacing: 16) {
                        Text("Code Revealed!")
                            .font(.headline)
                            .foregroundColor(.green)

                        Text(code)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.1))
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }
                    .padding()
                } else if store.isScratching {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)

                        Text("Scratching...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "rectangle.dashed")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)

                        Text("Tap the button below to scratch")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button {
                    store.send(.scratchButtonTapped)
                } label: {
                    Text("Scratch")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(store.canScratch ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!store.canScratch)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Scratch Card")
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
        }
    }
}

#Preview {
    ScratchView(
        store: Store(
            initialState: ScratchFeature.State(currentCardState: .unscratched)
        ) {
            ScratchFeature()
        }
    )
}
