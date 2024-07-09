//
//  SignUpViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

class SignUpViewModel: ObservableObject {
    var userId = ""
    @Published var newName = ""
    @Published var newUsername = ""
    @Published var isSearchingUsers = false
    @Published var isCheckingUsername = false
    @Published var isCreatingAccount = false
    @Published var isNewUsernameisAvailable = true
    
    @Published var authState: AuthState
    private var debouncer = Debouncer(delay: 0.5)
    
    init(authState: AuthState) {
        self.authState = authState
    }
    
    func checkUsernameAvailability() {
        debouncer.debounce { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isCheckingUsername = true
            }
            
            Task {
                guard !self.newUsername.isEmpty else {
                    DispatchQueue.main.async {
                        self.isCheckingUsername = false
                        self.isNewUsernameisAvailable = false
                    }
                    print("Please provide a username")
                    return
                }
                
                let users = await self.findUsers(username: self.newUsername)
                
                DispatchQueue.main.async {
                    self.isNewUsernameisAvailable = users.isEmpty
                    self.isCheckingUsername = false
                }
                
                print("checkUsernameAvailability: \(users)")
            }
        }
    }
    
    func findUsers(id: String? = nil, name: String? = nil, username: String? = nil) async -> [User] {
        var users = [User]()
        
        DispatchQueue.main.async {
            self.isSearchingUsers = true
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
                self.isSearchingUsers = false
            }
            return []
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print("findUsersRaw: \(String(data: data, encoding: .utf8)!)")
            
            // Try to decode the JSON
            do {
                let decodedResponse = try JSONDecoder().decode([String: [User]].self, from: data)
                users = decodedResponse["result"] ?? []
                print("findUsers: \(users)")
            } catch let decodeError {
                print("findUsers: Decoding failed! \(decodeError)")
            }
        } catch {
            print("Failed to fetch users: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.isSearchingUsers = false
        }
        
        return users
    }
    
    func createUser() async -> User? {
        guard !userId.isEmpty && !newName.isEmpty && !newUsername.isEmpty else {
            print("Please provide all required information")
            return nil
        }
        
        DispatchQueue.main.async {
            self.isCreatingAccount = true
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
            
            // Try to decode the JSON
            do {
                let decodedResponse = try JSONDecoder().decode([String: User].self, from: data)
                if let user = decodedResponse["result"] {
                    print("User created: \(user)")
                    DispatchQueue.main.async {
                        self.authState.currentUser = user
                        self.isCreatingAccount = false
                    }
                    return user
                } else {
                    print("Failed to find user in decoded response")
                }
            } catch let decodeError {
                print("Failed to decode user: \(decodeError)")
            }
        } catch {
            print("Failed to create user: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.isCreatingAccount = false
        }
        
        return nil
    }
}
