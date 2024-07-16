//
//  ProfileViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    
    func editUser(name: String, username: String) async -> User? {
        guard !(name.isEmpty && username.isEmpty) else {
            print("Please provide name or username to update")
            return nil
        }
        
        let body = ["name": name, "username": username]
        
        let result: HTTPResponse<User> = await sendRequest(endpoint: "users/\(currentUserId)", body: body, method: .PUT)

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
        let result: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "users/\(currentUserId)", body: nil, method: .DELETE)

        switch result {
        case .success:
            print("User successfully deleted")
            return true
        case .failure(let error):
            print("Failed to delete user: \(error)")
            return false
        }
    }
    
    func fetchWorkouts(for userId: String) async -> [Workout]? {
//        DispatchQueue.main.async {
//            self.state = .loading
//        }
        
        let result: HTTPResponse<[Workout]> = await sendRequest(endpoint: "workouts?findMany=true&includeAll=true&isTemplate=false&ownerId=\(userId)", body: nil, method: .GET)
                
        switch result {
        case .success(let workouts):
            print("Workouts fetched: \(workouts)")
//            DispatchQueue.main.async {
//                self.state = .success
//            }
            return workouts
        case .failure(let error):
            print("Failed to fetch workouts: \(error)")
//            DispatchQueue.main.async {
//                self.state = .failure(error)
//            }
            return nil
        }
    }
    
}
