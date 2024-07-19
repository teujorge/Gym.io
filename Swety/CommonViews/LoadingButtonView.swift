//
//  LoadingButtonView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

struct LoadingButtonView: View {
    
    let title: String
    let state: LoaderState
    let disabled: Bool
    let showErrorMessage: Bool
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
                    .background(disabled ? Color.accent.opacity(0.25) : Color.accent)
                    .cornerRadius(.medium)
                    .shadow(radius: .small)
            default:
                LoaderView(size: 40, weight: .light, state: state, showErrorMessage: showErrorMessage)
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
            LoadingButtonView(title:"hello there", state: loaderState, disabled: disabled, showErrorMessage: true) {}
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
                    loaderState = .failure("error messsage")
                }
                Button("Disabled") {
                    disabled.toggle()
                }
            }
        }
        .padding()
    }
}
