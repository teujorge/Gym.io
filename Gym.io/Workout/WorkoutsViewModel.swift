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
        let url = URL(string: "https://gym-io-api.vercel.app/api/workouts?findMany=true&includeAll=true&ownerId=\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print("fetchWorkoutsRaw: \(String(data: data, encoding: .utf8)!)")
            
            do {
                let decodedResponse = try JSONDecoder().decode([String: [Workout]?].self, from: data)
                if let workouts = decodedResponse["data"] {
                    print("Workouts fetched: \(workouts ?? [])")
                    return workouts
                } else {
                    print("Failed to find workouts in decoded response")
                }
            } catch let decodeError {
                print("Failed to decode workouts: \(decodeError)")
            }
        } catch {
            print("Failed to fetch workouts: \(error.localizedDescription)")
        }
        
        return nil
    }
    
}
