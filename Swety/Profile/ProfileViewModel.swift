//
//  ProfileViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/9/24.
//

import Foundation

enum HistorySelections: String, CaseIterable, Identifiable {
    case workouts
    case exercises

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .workouts: return "Workouts"
        case .exercises: return "Exercises"
        }
    }
}

class ProfileViewModel: ObservableObject {
    
    @Published var isPresentingSettings = false
    @Published var currentLanguage = Language.english
    
    @Published var selectedPickerTab: HistorySelections = .workouts
    @Published var exercisesHistory: [String: [Exercise]] = [:]
    
    @Published var workoutsState: LoaderState = .idle
    @Published var exercisesState: LoaderState = .idle
    var state: LoaderState {
        if workoutsState == .loading || exercisesState == .loading {
            return .loading
        }
        if workoutsState == .success && exercisesState == .success {
            return .success
        }
        if workoutsState == .idle && exercisesState == .idle {
            return .idle
        }
        if case let .failure(workoutsError) = workoutsState {
            return .failure(workoutsError)
        }
        if case let .failure(exercisesError) = exercisesState {
            return .failure(exercisesError)
        }
        return .idle
    }
    
    var workoutsCursor: String? = nil
    var exercisesCursor: String? = nil
    
    func editUser(name: String, username: String) async -> User? {
        guard !(name.isEmpty && username.isEmpty) else {
            print("Please provide name or username to update")
            return nil
        }
        
        let body = ["name": name, "username": username]
        let result: HTTPResponse<User> = await sendRequest(endpoint: "/users/\(currentUserId)", body: body, method: .PUT)
        
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
        let result: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "/users/\(currentUserId)", body: nil, method: .DELETE)
        
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
        DispatchQueue.main.async {
            self.workoutsState = .loading
        }
        
        let result: HTTPResponse<[Workout]> = await sendRequest(
            endpoint: "/workouts/history",
            queryItems: [
                URLQueryItem(name: "findMany", value: "true"),
                URLQueryItem(name: "includeAll", value: "true"),
                URLQueryItem(name: "ownerId", value: userId),
                URLQueryItem(name: "cursor", value: workoutsCursor)
            ],
            method: .GET
        )
        
        switch result {
        case .success(let workouts):
            print("Workout history fetched: \(workouts)")
            DispatchQueue.main.async {
                self.workoutsState = .success
            }
            if workouts.count == 10 {
                workoutsCursor = workouts.last?.id
            }
            return workouts
        case .failure(let error):
            print("Failed to fetch workout history: \(error)")
            DispatchQueue.main.async {
                self.workoutsState = .failure(error)
            }
            return nil
        }
    }
    
    func fetchExercises(for userId: String) async -> [Exercise]? {
        DispatchQueue.main.async {
            self.exercisesState = .loading
        }
        
        let result: HTTPResponse<[Exercise]> = await sendRequest(
            endpoint: "/exercises/history",
            queryItems: [
                URLQueryItem(name: "findMany", value: "true"),
                URLQueryItem(name: "includeAll", value: "true"),
                URLQueryItem(name: "ownerId", value: userId),
                URLQueryItem(name: "cursor", value: exercisesCursor)
            ],
            method: .GET
        )
        
        switch result {
        case .success(let exercises):
            print("Exercise history fetched: \(exercises)")
            DispatchQueue.main.async {
                self.exercisesState = .success
            }
            if exercises.count == 10 {
                exercisesCursor = exercises.last?.id
            }
            return exercises
        case .failure(let error):
            print("Failed to fetch exercise history: \(error)")
            DispatchQueue.main.async {
                self.exercisesState = .failure(error)
            }
            return nil
        }
    }
    
}
