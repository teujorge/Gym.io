//
//  SignUpView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var isDisabled: Bool {
        viewModel.state == .creatingAccount || viewModel.state == .accountCreated
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accent)
                .padding(.top)
            
            LabeledTextFieldView(
                label: "Full name (optional):",
                placeholder: "Enter your full Name",
                text: $viewModel.newName,
                isDisabled: isDisabled
            )
            
            LabeledTextFieldView(
                label: "Username:",
                placeholder: "Enter a username",
                text: $viewModel.newUsername,
                error: viewModel.errorMessage,
                onChange: { _ in viewModel.checkUsernameAvailability() },
                isDisabled: isDisabled,
                keyboardType: .namePhonePad
            )
            
            LoadingButtonView(
                title: "Sign Up",
                state: viewModel.loaderState,
                disabled: isDisabled,
                action: { Task { await viewModel.createUser() } }
            )
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(.large)
        .shadow(radius: .medium)
        .padding()
        .animation(.easeInOut, value: viewModel.state)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SignUpView(viewModel: SignUpViewModel(authState: _previewAuthCreateAccountState))
    }
}

