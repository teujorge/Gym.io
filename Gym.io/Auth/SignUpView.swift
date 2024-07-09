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
        VStack {
            Text("Welcome!")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            VStack(alignment: .leading) {
                Text("Full name (optional):")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("Enter your full Name", text: $viewModel.newName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("Username:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("Enter a username", text: $viewModel.newUsername)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(viewModel.state == .usernameNotAvailable ? Color.red.opacity(0.2) : Color.clear)
                    .padding(.bottom)
                    .onChange(of: viewModel.newUsername) {
                        viewModel.checkUsernameAvailability()
                    }
            }
            .padding(.horizontal)
            
            if viewModel.state == .queringUsers || viewModel.state == .creatingAccount {
                ProgressView()
                    .padding()
            } else {
                Button("Continue") {
                    Task {
                        await viewModel.createUser()
                    }
                }
                .disabled(viewModel.state != .usernameAvailable || viewModel.newUsername.isEmpty)
            }
            
            if case .error(let message) = viewModel.state {
                Text(message)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        SignUpView(viewModel: SignUpViewModel(authState: _previewAuthCreateAccountState))
    }
}
