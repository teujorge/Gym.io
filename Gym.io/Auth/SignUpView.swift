//
//  SignUpView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top)
            
            LabeledTextField(
                label: "Full name (optional):",
                placeholder: "Enter your full Name",
                text: $viewModel.newName
            )
            
            LabeledTextField(
                label: "Username:",
                placeholder: "Enter a username",
                text: $viewModel.newUsername,
                error: viewModel.errorMessage,
                onChange: { _ in viewModel.checkUsernameAvailability() }
            )
            
            LoadingButton(
                action: { Task { await viewModel.createUser() } },
                isLoading: viewModel.state == .queringUsers || viewModel.state == .creatingAccount,
                isEnabled: viewModel.state == .usernameAvailable && !viewModel.newUsername.isEmpty,
                title: "Continue"
            )
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
        .animation(.easeInOut, value: viewModel.state) // Animates state changes
    }
}

#Preview {
    NavigationView {
        SignUpView(viewModel: SignUpViewModel(authState: _previewAuthCreateAccountState))
    }
}

