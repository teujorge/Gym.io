//
//  SignUpView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    @State private var showError: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Full name (optional):")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("Enter your full Name", text: $viewModel.newName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Username:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("Enter a username", text: $viewModel.newUsername)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 10)
                    .foregroundColor(viewModel.state == .usernameNotAvailable ? Color.red : Color.primary)
                    .onChange(of: viewModel.newUsername) {                        viewModel.checkUsernameAvailability()
                    }
            }
            .padding(.horizontal)
            
            if viewModel.state == .queringUsers || viewModel.state == .creatingAccount {
                ProgressView()
                    .padding()
                    .transition(.scale)
            } else {
                Button(action: {
                    Task {
                        await viewModel.createUser()
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.state == .usernameAvailable && !viewModel.newUsername.isEmpty ? Color.blue : Color.gray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                }
                .transition(.opacity)
                .disabled(viewModel.state != .usernameAvailable || viewModel.newUsername.isEmpty)
                .padding()
            }
            
            if case .error(let message) = viewModel.state {
                Text(message)
                    .foregroundColor(.red)
                    .padding()
                    .transition(.slide)
                    .onAppear {
                        withAnimation {
                            showError = true
                        }
                    }
                    .onDisappear {
                        withAnimation {
                            showError = false
                        }
                    }
            }

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

