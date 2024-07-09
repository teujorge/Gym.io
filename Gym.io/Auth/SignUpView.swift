//
//  SignUpView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    
    var body: some View {
        ScrollView {
            Text("Please enter your username")
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.top)
                .padding(.horizontal)
            
            TextField("Username", text: $viewModel.username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom)
                .padding(.horizontal)
            
            Text("Please enter your name")
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            HStack {
                TextField("First name", text: $viewModel.firstName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom)
                    .padding(.leading)
                TextField("Last name", text: $viewModel.lastName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom)
                    .padding(.trailing)
            }
            
            Button(action: viewModel.createAccount) {
                VStack {
                    if viewModel.isCreatingAccount {
                        ProgressView()
                    }
                    else {
                        Text("Create account")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .animation(.easeInOut, value: viewModel.isCreatingAccount)
            }
            .disabled(viewModel.isCreatingAccount)
        }
        .navigationTitle("Sign Up")
    }
    
}



#Preview {
    NavigationView {
        SignUpView()
    }
}
