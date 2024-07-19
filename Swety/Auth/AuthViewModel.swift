//
//  AuthViewModel.swift
//  Swety
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
    
    func handleAlreadySignedIn() {
        guard state != .signUp else {
            print("handleAlreadySignedIn cancelled -> user is in sign up")
            return
        }
        
        print("handleAlreadySignedIn")
        if let accessToken = currentUserAccessToken {
            DispatchQueue.main.async {
                self.state = .authenticating
            }
            print("User Access Token: \(accessToken)")
            
            Task {
                let dbUser = await findUser()
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
            print("No user access token saved")
        }
    }
    
    private func findUser() async -> User? {
        print()
        print("findUser")
        print()
        
        let result: HTTPResponse<User> = await sendRequest(
            endpoint: "users",
            queryItems: [
                URLQueryItem(name: "id", value: currentUserId),
            ],
            method: .GET
        )
        
        switch result {
        case .success(let user):
            return user
        case .failure(let error):
            print("Failed to find user: \(error)")
            return nil
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
//                let appleUserID = credential.user
                let identityToken = credential.identityToken
//                let authorizationCode = credential.authorizationCode
                
//                signUpViewModel.userId = appleUserID
                
                Task {
                    await signIn(
//                        userIdentifier: appleUserID,
                        identityToken: identityToken
//                        authorizationCode: authorizationCode
                    )
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.state = .signIn
            }
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
    
    private func signIn(
        userIdentifier: String? = nil,
        identityToken: Data? = nil
//        authorizationCode: Data?
    ) async {
        print()
        print("sendTokensToServer")
        print()
        
        let identityTokenString: String = identityToken.flatMap { String(data: $0, encoding: .utf8) } ?? ""
//        let authorizationCodeString: String = authorizationCode.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        
        let authResponse: HTTPResponse<Auth?> = await sendRequest(
            endpoint: "auth/signin",
            body: [
                "userId": userIdentifier,
                "identityToken": identityTokenString,
//                "authorizationCode": authorizationCodeString
            ],
            method: .POST
        )
        
        switch authResponse {
        case .success(let auth):
            currentUserAccessToken = auth?.accessToken ?? nil
            currentUserRefreshToken = auth?.refreshToken ?? nil
            print("User authenticated: \(String(describing: auth))")
            if let auth = auth {
                // auth object returned
                currentUserId = auth.userId
                DispatchQueue.main.async {
                    self.authState.currentUser = auth.user
                    self.state = .authenticated
                }
            } else {
                // nil object returned
                DispatchQueue.main.async {
//                    self.signUpViewModel.userId = userIdentifier
                    self.signUpViewModel.identityToken = identityTokenString
//                    self.signUpViewModel.authorizationCode = authorizationCodeString
                    self.state = .signUp
                }
            }
        case .failure(let error):
            print("Failed to authenticate with server: \(error)")
            DispatchQueue.main.async {
                self.state = .signIn
            }
        }

    }
    
}
