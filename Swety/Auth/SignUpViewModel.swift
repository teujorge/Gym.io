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
    var userId = ""
    @Published var newName = ""
    @Published var newUsername = ""
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
                let user = await self.findUser(username: self.newUsername)
                
                DispatchQueue.main.async {
                    self.state = user == nil ? .usernameAvailable : .error("Username already taken")
                }
                
                print("checkUsernameAvailability: \(String(describing: user?.username))")
            }
        }
    }
    
    func findUser(id: String? = nil, name: String? = nil, username: String? = nil) async -> User? {
        DispatchQueue.main.async {
            self.state = .queringUsers
        }
        
        let result: HTTPResponse<User> = await sendRequest(
            endpoint: "users",
            queryItems: [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "matchMode", value: "exact")
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
    
    func createUser() async -> User? {
        guard !userId.isEmpty && !newName.isEmpty && !newUsername.isEmpty else {
            print("Please provide all required information")
            DispatchQueue.main.async {
                self.state = .error("Please provide all required information")
            }
            return nil
        }
        
        DispatchQueue.main.async {
            self.state = .creatingAccount
        }
    
        let body = [
            "id": userId,
            "name": newName,
            "username": newUsername
        ]
        
        let result: HTTPResponse<User> = await sendRequest(endpoint: "users", body: body, method: .POST)
        
        switch result {
        case .success(let user):
            print("User created: \(user)")
            DispatchQueue.main.async {
                self.authState.currentUser = user
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
