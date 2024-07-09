//
//  SignInView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI
import Combine

struct SignInView: View {
    @EnvironmentObject var authState: AuthState
    @StateObject private var viewModel = SignInViewModel()
    
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
            
            VStack {
                if viewModel.isSearching {
                    ProgressView()
                        .padding()
                } else {
                    VStack {
                        ForEach(viewModel.userProfiles, id: \.id) { user in
                            Button(action: { authState.currentUser = user }) {
                                HStack {
                                    Text(user.username)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(user.name)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Sign In")
        .onAppear {
            viewModel.setupDebounce()
        }
    }
    
}

#Preview {
    NavigationView {
        SignInView()
            .environmentObject(AuthState())
    }
}
