//
//  SignUpViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

enum SignUpState: Equatable {
    case idle
    case queringUsers
    case usernameAvailable
    case creatingAccount
    case accountCreated
    case error(String)
}

class SignUpViewModel: ObservableObject {    
//    var userId = ""
    var identityToken = ""
//    var authorizationCode = ""
    
    @Published var newName = "" {
        didSet {
            if errorMessage?.lowercased().contains(" name") ?? false {
                state = .idle
            }
        }
    }
    @Published var newUsername = ""
    @Published var birthday = Date() {
        didSet {
            if errorMessage?.lowercased().contains("birthday") ?? false {
                state = .idle
            }
        }
    }
    @Published var isPresentingBirthdayPicker = false
    @Published var selectedUnit: Units = .metric
    @Published var state: SignUpState = .idle
    
    @Published var authState: AuthState
    private var debouncer = Debouncer(delay: 0.5)
    
    init(authState: AuthState) {
        self.authState = authState
    }
    
    var loaderState: LoaderState {
        switch state {
        case .idle, .usernameAvailable:
            return .idle
        case .queringUsers, .creatingAccount:
            return .loading
        case .accountCreated:
            return .success
        case .error(let errMessage):
            return .failure(errMessage)
        }
    }
    
    var errorMessage: String? {
        if case .error(let message) = state {
            return message
        } else {
            return nil
        }
    }
    
    func checkUsernameAvailability() {
        debouncer.debounce { [weak self] in
            guard let self = self else { return }
            
            guard !self.newUsername.isEmpty else {
                DispatchQueue.main.async {
                    self.state = .error("Please provide a username")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.state = .queringUsers
            }
            
            Task {
                let user = await self.findUsername(username: self.newUsername)
                
                DispatchQueue.main.async {
                    self.state = user == nil ? .usernameAvailable : .error("Username already taken")
                }
                
                print("checkUsernameAvailability: \(String(describing: user?.username))")
            }
        }
    }
    
    private func findUsername(username: String) async -> User? {
        print()
        print("findUsername")
        print()
        
        DispatchQueue.main.async {
            self.state = .queringUsers
        }
        
        let result: HTTPResponse<User> = await sendRequest(
            endpoint: "auth/signup/validate-username",
            queryItems: [
                URLQueryItem(name: "username", value: username),
            ],
            method: .GET
        )
        
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                self.state = .idle
            }
            return user
        case .failure(let error):
            print("Failed to find user: \(error)")
            DispatchQueue.main.async {
                self.state = .error(error)
            }
            return nil
        }
    }
    
    func signUp() async -> User? {
        print()
        print("signUp")
        print()
        
#if !DEBUG
        guard !userId.isEmpty else {
            print("We were unable to create your account")
            DispatchQueue.main.async {
                self.state = .error("We were unable to create your account")
            }
            return nil
        }
#endif
        
        guard !newName.isEmpty else {
            print("Please provide your name")
            DispatchQueue.main.async {
                self.state = .error("Please provide your name")
            }
            return nil
        }
        
        guard !newUsername.isEmpty else {
            print("Please provide a username")
            DispatchQueue.main.async {
                self.state = .error("Please provide a username")
            }
            return nil
        }
        
        guard birthday.timeIntervalSinceNow < -60 * 60 * 24 * 365 * 13 else {
            print("Please provide a valid birthday")
            DispatchQueue.main.async {
                self.state = .error("Please provide a valid birthday")
            }
            return nil
        }
        
        DispatchQueue.main.async {
            self.state = .creatingAccount
        }
        
        let result: HTTPResponse<User> = await sendRequest(
            endpoint: "auth/signup",
            queryItems: [
                URLQueryItem(name: "identityToken", value: identityToken),
//                URLQueryItem(name: "authorizationCode", value: authorizationCode)
            ],
            body: User(
                id: "",
                username: newUsername,
                name: newName,
                birthday: birthday,
                units: selectedUnit
            ),
            method: .POST
        )
        
        switch result {
        case .success(let user):
            print("User created: \(user)")
            DispatchQueue.main.async {
                currentUserAccessToken = user.auth?.accessToken ?? nil
                currentUserRefreshToken = user.auth?.refreshToken ?? nil
                if let auth = user.auth {
//                    self.auth = auth
                }
//                self.auth.user = user
                self.state = .accountCreated
            }
            return user
        case .failure(let error):
            print("Failed to create user: \(error)")
            DispatchQueue.main.async {
                self.state = .error(error)
            }
            return nil
        }
    }
}
