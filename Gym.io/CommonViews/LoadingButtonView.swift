//
//  LoadingButtonView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

struct LoadingButtonView: View {
    
    let title: String
    let state: LoaderState
    let disabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: { action() }) {
            switch state {
            case .idle:
                Text(title)
                    .font(.headline)
                    .foregroundColor(disabled ? .gray : .white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(disabled ? Color.blue.opacity(0.25) : Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            default:
                LoaderView(size: 40, weight: .light, state: state)
            }
        }
        .frame(height: 50)
        .transition(.opacity)
        .disabled(disabled)
        .padding()
        .animation(.easeInOut, value: state)
    }
}

#Preview {
    LoaderButtonPreview()
}

private struct LoaderButtonPreview: View {
    @State private var loaderState: LoaderState = .loading
    @State private var disabled = false
    
    var body: some View {
        VStack {
                LoadingButtonView(title:"hello there", state: loaderState, disabled: disabled) {}
                    .padding()
            
            HStack {
                Button("Idle") {
                    loaderState = .idle
                }
                Button("Loading") {
                    loaderState = .loading
                }
                Button("Success") {
                    loaderState = .success
                }
                Button("Failure") {
                    loaderState = .failure
                }
                Button("Disabled") {
                    disabled.toggle()
                }
            }
        }
        .padding()
    }
}
