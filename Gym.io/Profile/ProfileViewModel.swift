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
        //            self.state = .loading
        
        let result: HTTPResponse<[Workout]> = await sendRequest(
            endpoint: "workouts",
            queryItems: [
                URLQueryItem(name: "findMany", value: "true"),
                URLQueryItem(name: "includeAll", value: "true"),
                URLQueryItem(name: "isTemplate", value: "false"),
                URLQueryItem(name: "ownerId", value: userId)
            ],
            method: .GET
        )
        
        switch result {
        case .success(let workouts):
            print("Workout history fetched: \(workouts)")
            //            DispatchQueue.main.async {
            //                self.state = .success
            //            }
            return workouts
        case .failure(let error):
            print("Failed to fetch workout history: \(error)")
            //            DispatchQueue.main.async {
            //                self.state = .failure(error)
            //            }
            return nil
        }
    }
    
}
