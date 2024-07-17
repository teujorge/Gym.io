//
//  ProfileViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/9/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    
    @Published var state: LoaderState = .idle
    var workoutsCursor: String? = nil
    
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
        self.state = .loading
        
        let result: HTTPResponse<WorkoutsWithCursor> = await sendRequest(
            endpoint: "users/\(userId)/workouts",
            queryItems: [
                URLQueryItem(name: "cursor", value: workoutsCursor)
            ],
            method: .GET
        )
        
        switch result {
        case .success(let data):
            print("Workout history fetched: \(data)")
            DispatchQueue.main.async {
                self.state = .success
            }
            workoutsCursor = data.nextCursor
            return data.workouts
        case .failure(let error):
            print("Failed to fetch workout history: \(error)")
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
            return nil
        }
    }
    
}

private struct WorkoutsWithCursor: Codable {
    var workouts: [Workout]
    var nextCursor: String?
}
