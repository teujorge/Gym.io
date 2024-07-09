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
                    .padding(.bottom)
                    .onChange(of: viewModel.newUsername) {
                        viewModel.checkUsernameAvailability()
                    }
                    .background(viewModel.isNewUsernameisAvailable ? Color.clear : Color.red.opacity(0.2))
            }
            .padding(.horizontal)
            
            if viewModel.isSearchingUsers {
                ProgressView()
                    .padding()
            } else {
                Button("Continue") {
                    Task {
                        await viewModel.createUser()
                    }
                }
                .disabled(!viewModel.isNewUsernameisAvailable || viewModel.newUsername.isEmpty)
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
