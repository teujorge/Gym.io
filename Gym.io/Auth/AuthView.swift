//
//  AuthView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel
    
    init(authState: AuthState) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authState: authState))
    }
    
    init(authModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: authModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                if viewModel.isAuthenticating {
                    ProgressView()
                        .transition(.opacity)
                } else {
                    if viewModel.showSignUpView {
                        SignUpView(viewModel: viewModel.signUpViewModel)
                            .transition(.opacity)
                    }
                    else {
                        SignInView(viewModel: viewModel)
                            .transition(.opacity)
                    }
                }
            }
            .animation(.default, value: viewModel.showSignUpView)
            .navigationTitle("Gym.io")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    if viewModel.showSignUpView {
                        Button(action: { viewModel.showSignUpView = false }) {
                            Image(systemName: "chevron.backward")
                                .font(.caption)
                                .accessibilityLabel("Back")
                                .accessibilityHint("Go back to sign in")
                                .accessibilityIdentifier("back_button")
                            Text("Back")
                        }
                    }
                }
            }
        }
        .environmentObject(viewModel.authState)
    }
    
    struct SignInView: View {
        @Environment(\.colorScheme) var colorScheme
        @StateObject var viewModel: AuthViewModel
        
        var body: some View {
            VStack {
                Spacer()
                Image(systemName: "dumbbell.fill")
                    .resizable()
                    .scaledToFit()
                    .padding()
                Spacer()
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        viewModel.handleSignInWithApple(result: result)
                    }
                )
                .signInWithAppleButtonStyle(colorScheme == .dark ? .whiteOutline : .black)
                .cornerRadius(10)
                .frame(height: 50)
            }
            .padding()
        }
    }
    
}


#Preview("signed out") {
    AuthView(authState: AuthState())
        .environmentObject(_previewAuthSignedOutState)
}

#Preview("register") {
    let viewModel = AuthViewModel(authState: _previewAuthCreateAccountState)
    viewModel.showSignUpView = true
    viewModel.signUpViewModel.userId = UUID().uuidString
    viewModel.signUpViewModel.newName = "Matheus Jorge"
    return AuthView(authModel: viewModel)
        .environmentObject(_previewAuthCreateAccountState)
}
