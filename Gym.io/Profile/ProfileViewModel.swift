//
//  ProfileViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    let userId = UserDefaults.standard.string(forKey: .userId)
        
    func editUser(name: String, username: String) async -> User? {
        guard let userId = userId else {
            print("Could not find userId in UserDefaults")
            return nil
        }
        
        guard !(name.isEmpty && username.isEmpty) else {
            print("Please provide name or username to update")
            return nil
        }
        
        let body = ["name": name, "username": username]
        
        let result: HTTPResponse<User> = await sendRequest(endpoint: "users/\(userId)", body: body, method: .PUT)

        switch result {
        case .success(let user):
            print("User edited: \(user)")
            return user
        case .failure(let error):
            print("Failed to edit user: \(error)")
            return nil
        }
    }
    
    func deleteUser() async -> Bool {
        guard let userId = userId else {
            print("Could not find userId in UserDefaults")
            return false
        }

        let result: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "users/\(userId)", body: nil, method: .DELETE)

        switch result {
        case .success:
            print("User successfully deleted")
            return true
        case .failure(let error):
            print("Failed to delete user: \(error)")
            return false
        }
    }
    
}
