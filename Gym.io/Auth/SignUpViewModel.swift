//
//  SignUpViewModel.swift
//  Gym.io
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
                let users = await self.findUsers(username: self.newUsername)
                
                DispatchQueue.main.async {
                    self.state = users.isEmpty ? .usernameAvailable : .error("Username already taken")
                }
                
                print("checkUsernameAvailability: \(users)")
            }
        }
    }
    
    func findUsers(id: String? = nil, name: String? = nil, username: String? = nil) async -> [User] {
        var users = [User]()
        
        DispatchQueue.main.async {
            self.state = .queringUsers
        }
        
        var components = URLComponents(string: "https://gym-io-api.vercel.app/api/users")!
        components.queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "matchMode", value: "exact")
        ]
        
        guard let url = components.url else {
            print("Invalid URL")
            DispatchQueue.main.async {
                self.state = .error("Invalid URL")
            }
            return []
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print("findUsersRaw: \(String(data: data, encoding: .utf8)!)")
            
            do {
                let decodedResponse = try JSONDecoder().decode([String: [User]].self, from: data)
                users = decodedResponse["data"] ?? []
                print("findUsers: \(users)")
            } catch let decodeError {
                print("findUsers: Decoding failed! \(decodeError)")
            }
        } catch {
            print("Failed to fetch users: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.state = .error(error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async {
            self.state = .idle
        }
        
        return users
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
        
        let url = URL(string: "https://gym-io-api.vercel.app/api/users")!
        let body = [
            "id": userId,
            "name": newName,
            "username": newUsername
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print("createUserRaw: \(String(data: data, encoding: .utf8)!)")
            
            do {
                let decodedResponse = try JSONDecoder().decode([String: User].self, from: data)
                if let user = decodedResponse["data"] {
                    print("User created: \(user)")
                    DispatchQueue.main.async {
                        self.authState.currentUser = user
                        self.state = .accountCreated
                    }
                    return user
                } else {
                    print("Failed to find user in decoded response")
                }
            } catch let decodeError {
                print("Failed to decode user: \(decodeError)")
                DispatchQueue.main.async {
                    self.state = .error(decodeError.localizedDescription)
                }
            }
        } catch {
            print("Failed to create user: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.state = .error(error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async {
            self.state = .idle
        }
        
        return nil
    }
}
