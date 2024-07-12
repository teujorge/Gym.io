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
    case authenticated
}

class AuthViewModel: ObservableObject {
    @Published var authState: AuthState
    @Published var signUpViewModel: SignUpViewModel
    @Published var state: AuthViewState = .authenticating
    
    init(authState: AuthState) {
        self.authState = authState
        self.signUpViewModel = SignUpViewModel(authState: authState)
    }
    
    func autoSignIn() {
        guard state != .signUp else {
            print("Auto sign cancelled -> user is in sign up")
            return
        }
        
        print("Auto sign")
        if let userId = UserDefaults.standard.string(forKey: .userId) {
            DispatchQueue.main.async {
                self.state = .authenticating
            }
            print("User ID: \(userId)")
            
            Task {
                let dbUser = await signUpViewModel.findUser(id: userId)
                DispatchQueue.main.async {
                    if let user = dbUser {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.authState.currentUser = user
                        }
                        self.state = .authenticated
                    } else {
                        self.state = .signIn
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.state = .signIn
            }
            print("No user ID saved")
        }
    }
    
    func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        DispatchQueue.main.async {
            self.state = .authenticating
        }
        
        switch result {
        case .success(let authResults):
            print("Authorization successful.")
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                let appleUserID = credential.user
                // let appleName = credential.fullName
                
                // DispatchQueue.main.async {
                //     self.signUpViewModel.newName = appleName.map { "\($0.givenName ?? "") \($0.familyName ?? "")" } ?? ""
                //     self.signUpViewModel.newUsername = appleName?.nickname ?? ""
                // }
                
                currentUserId = appleUserID
                signUpViewModel.userId = appleUserID
                
                Task {
                    let dbUser = await self.signUpViewModel.findUser(id: appleUserID)
                    DispatchQueue.main.async {
                        if let user = dbUser {
                            print("User found in the database")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.authState.currentUser = user
                            }
                            self.state = .authenticated
                        } else {
                            print("User not found in the database")
                            self.state = .signUp
                        }
                    }
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.state = .signIn
            }
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
}
