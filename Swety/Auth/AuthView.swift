//
//  AuthView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel
    
    #if DEBUG
    init(authState: AuthState) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authState: authState))
    }
    #endif
    
    init(authModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: authModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                switch viewModel.state {                    
                case .authenticating, .authenticated:
                    LoaderView(size: 100, weight: .thin, state: viewModel.state == .authenticating ? .loading : .success)
                        .transition(.opacity)
                case .signUp:
                    SignUpView(viewModel: viewModel.signUpViewModel)
                        .transition(.opacity)
                case .signIn:
                    SignInView(viewModel: viewModel)
                        .transition(.opacity)
                }
            }
            .animation(.default, value: viewModel.state)
            .navigationTitle("Swety")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    if viewModel.state == .signUp {
                        Button(action: { viewModel.state = .signIn }) {
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
        .onAppear(perform: viewModel.autoSignIn)
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
                .cornerRadius(.medium)
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
    viewModel.state = .signUp
    viewModel.signUpViewModel.userId = UUID().uuidString
    viewModel.signUpViewModel.newName = "Matheus Jorge"
    return AuthView(authModel: viewModel)
        .environmentObject(_previewAuthCreateAccountState)
}
