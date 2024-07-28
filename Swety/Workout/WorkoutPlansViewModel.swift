//
//  WorkoutsViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/10/24.
//

import Foundation
import Combine

class WorkoutPlansViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var state: LoaderState = .idle {
        didSet {
            debounceStateChange()
        }
    }
    
    @Published var showWorkoutsInProgress = true
    @Published var showWorkoutPlans = true
    
    private var debounceTimer: AnyCancellable?
    
    private func debounceStateChange() {
        debounceTimer?.cancel()
        
        debounceTimer = Just(state)
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] newState in
                if newState == .success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.state = .idle
                    }
                }
            }
    }
    
    func fetchWorkoutPlans(for userId: String) async -> [WorkoutPlan]? {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<[WorkoutPlan]> = await sendRequest(
            endpoint: "/workouts/templates",
            queryItems: [
                URLQueryItem(name: "findMany", value: "true"),
                URLQueryItem(name: "includeAll", value: "true"),
                URLQueryItem(name: "ownerId", value: userId)
            ],
            method: .GET
        )
        
        switch result {
        case .success(let workouts):
            print("Workout plans fetched: \(workouts)")
            DispatchQueue.main.async {
                self.state = .success
            }
            return workouts
        case .failure(let error):
            print("Failed to fetch workout plans: \(error)")
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
            return nil
        }
    }
    
    func fetchWorkoutsInProgress(for userId: String) async -> [Workout]? {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<[Workout]> = await sendRequest(
            endpoint: "/workouts/history",
            queryItems: [
                URLQueryItem(name: "findMany", value: "true"),
                URLQueryItem(name: "includeAll", value: "true"),
                URLQueryItem(name: "ownerId", value: userId),
                URLQueryItem(name: "isInProgress", value: "true")
            ],
            method: .GET
        )
        
        switch result {
        case .success(let workouts):
            print("Workouts in progress fetched: \(workouts)")
            DispatchQueue.main.async {
                self.state = .success
            }
            return workouts
        case .failure(let error):
            print("Failed to fetch workouts in progress: \(error)")
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
            return nil
        }
        
    }
    
}
