//
//  AuthViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI
import AuthenticationServices

enum AuthViewState: Equatable {
    case signIn
    case signUp
    case authenticating
}

class AuthViewModel: ObservableObject {
    @Published var authState: AuthState
    @Published var signUpViewModel: SignUpViewModel
    @Published var viewState: AuthViewState = .authenticating
    
    init(authState: AuthState) {
        self.authState = authState
        self.signUpViewModel = SignUpViewModel(authState: authState)
    }
    
    func autoSignIn() {
        guard viewState != .signUp else {
            print("Auto sign cancelled -> user is in sign up")
            return
        }
        
        print("Auto sign")
        if let userId = UserDefaults.standard.string(forKey: .userId) {
            DispatchQueue.main.async {
                self.viewState = .authenticating
            }
            print("User ID: \(userId)")
            
            Task {
                let dbUsers = await signUpViewModel.findUsers(id: userId)
                DispatchQueue.main.async {
                    if let user = dbUsers.first {
                        self.authState.currentUser = user
                        self.viewState = .signIn
                    } else {
                        self.viewState = .signIn
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.viewState = .signIn
            }
            print("No user ID saved")
        }
    }
    
    func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        DispatchQueue.main.async {
            self.viewState = .authenticating
        }
        
        switch result {
        case .success(let authResults):
            print("Authorization successful.")
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                let appleUserID = credential.user
                let appleName = credential.fullName
                
                DispatchQueue.main.async {
                    self.signUpViewModel.newName = appleName.map { "\($0.givenName ?? "") \($0.familyName ?? "")" } ?? ""
                    self.signUpViewModel.newUsername = appleName?.nickname ?? ""
                }
                
                signUpViewModel.userId = appleUserID
                UserDefaults.standard.set(appleUserID, forKey: .userId)
                
                Task {
                    let dbUsers = await self.signUpViewModel.findUsers(id: appleUserID)
                    DispatchQueue.main.async {
                        if dbUsers.isEmpty {
                            print("User not found in the database")
                            self.viewState = .signUp
                        } else {
                            print("User found in the database")
                            self.authState.currentUser = dbUsers.first
                            self.viewState = .signIn
                        }
                    }
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.viewState = .signIn
            }
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
}
