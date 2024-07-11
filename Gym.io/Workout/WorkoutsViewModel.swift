//
//  WorkoutsViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

class WorkoutsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var isPresentingWorkoutForm = false
    
    func fetchWorkouts(for userId: String) async -> [Workout]? {
        let result: HTTPResponse<[Workout]> = await sendRequest(endpoint: "workouts?findMany=true&includeAll=true&ownerId=\(userId)", body: nil, method: .GET)
        
        switch result {
        case .success(let workouts):
            print("Workouts fetched: \(workouts)")
            return workouts
        case .failure(let error):
            print("Failed to fetch workouts: \(error)")
            return nil
        }
    }
    
}
