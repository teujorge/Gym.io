//
//  AuthViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI
import AuthenticationServices

class AuthViewModel: ObservableObject {
    @Published var authState: AuthState
    @Published var signUpViewModel: SignUpViewModel
    
    @Published var showSignUpView = false
    @Published var isSearchingUsers = false
    @Published var isAuthenticating = false
    
    init(authState: AuthState) {
        self.authState = authState
        self.signUpViewModel = SignUpViewModel(authState: authState)
    }
    
    func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        DispatchQueue.main.async {
            self.isAuthenticating = true
        }
        
        switch result {
        case .success(let authResults):
            print("Authorization successful.")
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                let appleUserID = credential.user
                let appleName = credential.fullName
                let appleEmail = credential.email
                
                // Pre-set registration vars
                DispatchQueue.main.async {
                    self.signUpViewModel.newName = appleName.map { "\($0.givenName ?? "") \($0.familyName ?? "")" } ?? ""
                    self.signUpViewModel.newUsername = appleName?.nickname ?? ""
                }
                
                signUpViewModel.userId = appleUserID
                
                // Fetch user using appleUserID
                Task {
                    let dbUsers = await self.signUpViewModel.findUsers(id: appleUserID)
                    DispatchQueue.main.async {
                        if dbUsers.isEmpty {
                            print("User not found in the database")
                            self.showSignUpView = true
                        } else {
                            print("User found in the database")
                            self.authState.currentUser = dbUsers.first
                        }
                        self.isAuthenticating = false
                    }
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.isAuthenticating = false
            }
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
    
}
